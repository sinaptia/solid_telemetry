module SolidTelemetry
  class SpansController < ApplicationController
    include Sortable

    before_action :set_span, only: :show

    def index
      @spans = apply_scopes(Span.roots).order(sort_column => sort_direction).page(params[:page])
    end

    def show
    end

    private

    def apply_scopes(scope)
      if params[:name].present?
        scope = scope.where(name: params[:name])
      end

      start_at = params[:start_at].try(:in_time_zone) || 2.hours.ago
      end_at = params[:end_at].try(:in_time_zone)

      scope.where(start_timestamp: start_at..end_at)
    end

    def default_sort_column
      "start_timestamp"
    end

    def set_span
      @span = Span.find params[:id]
    end
  end
end
