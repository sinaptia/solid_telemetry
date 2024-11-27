module SolidTelemetry
  class PerformanceItemsController < ApplicationController
    include Sortable

    before_action :set_performance_item, only: [:show]

    def index
      @performance_items = PerformanceItem.order(sort_column => sort_direction).page params[:page]
    end

    def show
    end

    private

    def default_sort_column
      "impact_score"
    end

    def set_performance_item
      @performance_item = PerformanceItem.find params[:id]
    end
  end
end
