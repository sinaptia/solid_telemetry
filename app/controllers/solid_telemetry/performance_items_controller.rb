module SolidTelemetry
  class PerformanceItemsController < ApplicationController
    before_action :set_performance_item, only: [:show]

    def index
      @performance_items = PerformanceItem.order(mean_duration: :desc).page params[:page]
    end

    def show
    end

    private

    def set_performance_item
      @performance_item = PerformanceItem.find params[:id]
    end
  end
end
