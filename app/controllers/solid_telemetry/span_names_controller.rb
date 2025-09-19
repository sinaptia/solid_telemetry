module SolidTelemetry
  class SpanNamesController < ApplicationController
    include Sortable

    before_action :set_span_name, only: [:show]
    before_action :set_time_range
    before_action :set_resolution

    def index
      @span_names = SpanName.joins(:spans).where(root: true, hidden: false, spans: {start_timestamp: @time_range}).order(sort_column => sort_direction).distinct.page(params[:page]).without_count
    end

    def show
      @metrics = {
        response_time: [
          SolidTelemetry::Metrics::ResponseTime::P50,
          SolidTelemetry::Metrics::ResponseTime::P95,
          SolidTelemetry::Metrics::ResponseTime::P99
        ],
        throughput: [
          SolidTelemetry::Metrics::Throughput::Successful,
          SolidTelemetry::Metrics::Throughput::Redirection,
          SolidTelemetry::Metrics::Throughput::ClientError,
          SolidTelemetry::Metrics::Throughput::ServerError
        ],
        active_job_throughput: [
          SolidTelemetry::Metrics::ActiveJobThroughput::Successful,
          SolidTelemetry::Metrics::ActiveJobThroughput::Failed
        ]
      }.map do |chart, metrics|
        {
          title: t(".#{chart}.title", default: chart.to_s),
          unit: metrics.first.unit,
          series: metrics.map do |metric|
            {
              name: t(".#{metric.name}", default: metric.name),
              data: metric.series(@span_name, @time_range, @resolution)
            }
          end
        }
      end
    end

    private

    def default_sort_column
      "name"
    end

    def filter_param
      {filter: {start_at: @start_at, end_at: @end_at, resolution: @resolution}}
    end

    def set_resolution
      @resolution = params.dig(:filter, :resolution).try(:to_i).try(:minutes) || 1.minute
    end

    def set_span_name
      @span_name = SpanName.find params[:id]
    end

    def set_time_range
      @start_at = params.dig(:filter, :start_at).try(:in_time_zone) || 2.hours.ago
      @end_at = params.dig(:filter, :end_at).try(:in_time_zone)

      @time_range = @start_at..@end_at
    end
  end
end
