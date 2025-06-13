module SolidTelemetry
  class MetricsController < ApplicationController
    before_action :set_host
    before_action :set_time_range
    before_action :set_resolution

    def index
      @metrics = SolidTelemetry.metrics.map do |group, metrics|
        {
          title: t(".#{group}.title", default: group.to_s),
          formatter: metrics.first.formatter,
          series: metrics.map do |metric|
            {
              name: t(".#{metric.name}", default: metric.name),
              data: metric.series(@host, @time_range, @resolution)
            }
          end
        }
      end
    end

    private

    def filter_param
      {filter: {host_id: @host.id, start_at: @start_at, end_at: @end_at, resolution: @resolution}}
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
