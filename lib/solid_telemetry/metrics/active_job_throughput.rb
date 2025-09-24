module SolidTelemetry
  module Metrics
    class ActiveJobThroughput < Base
      class Failed < ActiveJobThroughput
        name "active_job_throughput.failed"
        description "Failed jobs"

        def self.metric_data(host, time_range, resolution)
          super.where.not(total_recorded_events: 0).count
        end
      end

      class Successful < ActiveJobThroughput
        name "active_job_throughput.successful"
        description "Successful jobs"

        def self.metric_data(host, time_range, resolution)
          super.where(total_recorded_events: 0).count
        end
      end

      def self.metric_data(host_or_span_name, time_range, resolution)
        collection = if host_or_span_name.is_a? Host
          Span.by_host(host_or_span_name.name)
        elsif host_or_span_name.is_a? SpanName
          Span.where(span_name: host_or_span_name)
        end

        collection.roots.active_job.where(start_timestamp: time_range).group_by_minute(:start_timestamp, n: resolution.in_minutes.to_i)
      end
    end
  end
end
