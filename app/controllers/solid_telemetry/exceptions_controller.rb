module SolidTelemetry
  class ExceptionsController < ApplicationController
    include Sortable

    before_action :set_exception, only: %i[resolve show]

    def index
      @exceptions = Exception.unresolved.order(sort_column => sort_direction).page(params[:page])
    end

    def show
    end

    def resolve
      @exception.resolve
      redirect_to exceptions_path, notice: t(".success")
    end

    private

    def default_sort_column
      "updated_at"
    end

    def set_exception
      @exception = Exception.find params[:id]
    end
  end
end
