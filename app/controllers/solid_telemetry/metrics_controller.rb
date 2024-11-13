module SolidTelemetry
  class MetricsController < ApplicationController
    before_action :set_time_range

    def index
      @max_memory = SolidTelemetry::Metric.memory_total.last.try(:data_points).try(:first).try(:[], "value").try(:kilobytes)

      @cpu_metrics = grouped_metrics(:cpu).map { |k, v| [k.to_i.in_milliseconds, v.to_i] }
      @memory_used_metrics = grouped_metrics(:memory_used).map { |k, v| [k.to_i.in_milliseconds, v.to_i.kilobytes] }
      @memory_swap_metrics = grouped_metrics(:memory_swap).map { |k, v| [k.to_i.in_milliseconds, v.to_i.kilobytes] }

      @response_time_metrics = SolidTelemetry::Span.traces.http.where(start_timestamp: @time_range).group_by_minute(:start_timestamp).maximum(:duration).map { |k, v| [k.to_i.in_milliseconds, v.to_f] }

      @successful_http_metrics = SolidTelemetry::Span.traces.http.successful.where(start_timestamp: @time_range).group_by_minute(:start_timestamp).count.map { |k, v| [k.to_i.in_milliseconds, v] }
      @redirection_http_metrics = SolidTelemetry::Span.traces.http.redirection.where(start_timestamp: @time_range).group_by_minute(:start_timestamp).count.map { |k, v| [k.to_i.in_milliseconds, v] }
      @client_error_http_metrics = SolidTelemetry::Span.traces.http.client_error.where(start_timestamp: @time_range).group_by_minute(:start_timestamp).count.map { |k, v| [k.to_i.in_milliseconds, v] }
      @server_error_http_metrics = SolidTelemetry::Span.traces.http.server_error.where(start_timestamp: @time_range).group_by_minute(:start_timestamp).count.map { |k, v| [k.to_i.in_milliseconds, v] }
    end

    private

    def set_min
      @min = @time_range.first.to_i.in_milliseconds
    end

    def set_time_range
      @start_at = params[:start_at].try(:in_time_zone) || 2.hours.ago
      @end_at = params[:end_at].try(:in_time_zone)

      @time_range = @start_at..@end_at
    end

    def grouped_metrics(kind)
      SolidTelemetry::Metric.send(kind).where(time_unix_nano: @time_range).group_by_minute(:time_unix_nano).maximum("data_points->0->>'value'")
    end
  end
end
