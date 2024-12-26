module SolidTelemetry
  class MetricsController < ApplicationController
    before_action :set_host
    before_action :set_time_range
    before_action :set_resolution

    def index
      @max_memory = Metric.memory_total.last.try(:data_points).try(:first).try(:[], "value").try(:kilobytes)

      @cpu_series = [{
        name: t(".cpu_usage.max"), data: grouped_resource_metrics(:cpu).map { |k, v| [k.to_i.in_milliseconds, v] }
      }]

      @memory_series = [{
        name: t(".memory_usage.memory_used"), data: grouped_resource_metrics(:memory_used).map { |k, v| [k.to_i.in_milliseconds, v&.kilobytes] }
      }, {
        name: t(".memory_usage.swap_memory"), data: grouped_resource_metrics(:memory_swap).map { |k, v| [k.to_i.in_milliseconds, v&.kilobytes] }
      }]

      @response_time_series = [{
        name: t(".response_time.p50"), data: grouped_rack_metrics.percentile(:duration, 0.5).map { |k, v| [k.to_i.in_milliseconds, v.to_f] }
      }, {
        name: t(".response_time.p95"), data: grouped_rack_metrics.percentile(:duration, 0.95).map { |k, v| [k.to_i.in_milliseconds, v.to_f] }
      }, {
        name: t(".response_time.p99"), data: grouped_rack_metrics.percentile(:duration, 0.99).map { |k, v| [k.to_i.in_milliseconds, v.to_f] }
      }]

      @throughput_series = [{
        name: t(".throughput.successful"), data: grouped_rack_metrics.successful.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      }, {
        name: t(".throughput.redirection"), data: grouped_rack_metrics.redirection.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      }, {
        name: t(".throughput.client_error"), data: grouped_rack_metrics.client_error.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      }, {
        name: t(".throughput.server_error"), data: grouped_rack_metrics.server_error.count.map { |k, v| [k.to_i.in_milliseconds, v] }
      }]

      @active_job_throughput_series = [{
        name: t(".active_job_throughput.successful"), data: grouped_active_job_metrics.where(total_recorded_events: 0).count.map { |k, v| [k.to_i.in_milliseconds, v] }
      }, {
        name: t(".active_job_throughput.failed"), data: grouped_active_job_metrics.where.not(total_recorded_events: 0).count.map { |k, v| [k.to_i.in_milliseconds, v] }
      }]
    end

    private

    def filter_param
      {filter: {host_id: @host.id, start_at: @start_at, end_at: @end_at, resolution: @resolution}}
    end

    def grouped_active_job_metrics
      Span.by_host(@host.name).roots.active_job.where(start_timestamp: @time_range).group_by_minute(:start_timestamp, n: @resolution.in_minutes.to_i)
    end

    def grouped_rack_metrics
      Span.by_host(@host.name).roots.rack.where(start_timestamp: @time_range).group_by_minute(:start_timestamp, n: @resolution.in_minutes.to_i)
    end

    def grouped_resource_metrics(kind)
      Metric.by_host(@host.name).send(kind).group_by_minute(:time_unix_nano, range: @time_range, n: @resolution.in_minutes.to_i).maximum(:value)
    end

    def set_host
      @host = Host.find_by(id: params.dig(:filter, :host_id)) || Host.first
    end

    def set_resolution
      @resolution = params.dig(:filter, :resolution).try(:to_i).try(:minutes) || 1.minute
    end

    def set_time_range
      @start_at = params.dig(:filter, :start_at).try(:in_time_zone) || 2.hours.ago
      @end_at = params.dig(:filter, :end_at).try(:in_time_zone)

      @time_range = @start_at..@end_at
    end
  end
end
