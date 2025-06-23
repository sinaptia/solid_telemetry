module SolidTelemetry
  class SpansController < ApplicationController
    include Sortable

    before_action :set_filters, only: :index
    before_action :set_span, only: :show

    def index
      @spans = Span.includes(:events, :span_name).roots.where(**@filters).order(sort_column => sort_direction).page(params[:page]).without_count
    end

    def show
    end

    private

    def default_sort_column
      "start_timestamp"
    end

    def filter_param
      {filter: @filters}
    end

    def set_filters
      @filters = {
        solid_telemetry_span_name_id: params.dig(:filter, :span_name_id).presence,
        start_timestamp: (params.dig(:filter, :start_at).try(:in_time_zone)..params.dig(:filter, :end_at).try(:in_time_zone)).presence
      }.compact
    end

    def set_span
      @span = Span.find params[:id]
    end
  end
end
