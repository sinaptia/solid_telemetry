module SolidTelemetry
  class MetricsController < ApplicationController
    before_action :set_time_range

    def index
      @max_memory = Metric.memory_total.last.try(:data_points).try(:first).try(:[], "value").try(:kilobytes)

      @cpu_metrics = grouped_resource_metrics(:cpu).map { |k, v| [k.to_i.in_milliseconds, v] }
      @memory_used_metrics = grouped_resource_metrics(:memory_used).map { |k, v| [k.to_i.in_milliseconds, v.kilobytes] }
      @memory_swap_metrics = grouped_resource_metrics(:memory_swap).map { |k, v| [k.to_i.in_milliseconds, v.kilobytes] }

      @response_time_metrics = grouped_http_metrics.maximum(:duration).map { |k, v| [k.to_i.in_milliseconds, v.to_f] }

      @successful_http_metrics = grouped_http_metrics.successful.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      @redirection_http_metrics = grouped_http_metrics.redirection.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      @client_error_http_metrics = grouped_http_metrics.client_error.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      @server_error_http_metrics = grouped_http_metrics.server_error.count.map { |k, v| [k.to_i.in_milliseconds, v] }
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

    def grouped_resource_metrics(kind)
      Metric.send(kind).where(time_unix_nano: @time_range).group_by_minute(:time_unix_nano).maximum(Metric.data_point_condition)
    end

    def grouped_http_metrics
      Span.roots.http.where(start_timestamp: @time_range).group_by_minute(:start_timestamp)
    end
  end
end
