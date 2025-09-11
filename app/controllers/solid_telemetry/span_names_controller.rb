module SolidTelemetry
  class SpanNamesController < ApplicationController
    include Sortable

    before_action :set_time_range
    before_action :set_span_name, only: [:show]

    def index
      @span_names = SpanName.roots.joins(:spans).where("solid_telemetry_spans.start_timestamp": @time_range).distinct.page(params[:page])
    end

    def show
    end

    private

    def default_sort_column
      "impact_score"
    end

    def filter_param
      {filter: {start_at: @start_at, end_at: @end_at}}
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
