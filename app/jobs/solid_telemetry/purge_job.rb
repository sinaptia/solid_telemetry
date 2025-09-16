module SolidTelemetry
  class PurgeJob < ApplicationJob
    queue_as :default

    # Purges events, links, spans and metrics older than *time_ago*.
    # It deletes all performance items that don't have associated spans and updates those who still do.
    def perform(time_ago = 30.days.ago)
      SolidTelemetry::Event.joins(:span).where("solid_telemetry_spans.start_timestamp < ?", time_ago).delete_all
      SolidTelemetry::Link.joins(:span).where("solid_telemetry_spans.start_timestamp < ?", time_ago).delete_all
      SolidTelemetry::Span.where("start_timestamp < ?", time_ago).delete_all

      SolidTelemetry::Metric.where("time_unix_nano < ?", time_ago).delete_all

      SolidTelemetry::SpanName.find_each do |span_name|
        span_name.destroy if span_name.spans.none?
      end
    end
  end
end
