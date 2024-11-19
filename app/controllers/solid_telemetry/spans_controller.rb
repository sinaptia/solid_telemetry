module SolidTelemetry
  class SpansController < ApplicationController
    before_action :set_span, only: :show

    def index
      @spans = apply_scopes(Span.roots).order(start_timestamp: :desc).page(params[:page])
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

    def set_span
      @span = Span.find params[:id]
    end
  end
end
