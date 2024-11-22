module SolidTelemetry
  class ExceptionsController < ApplicationController
    before_action :set_exception, only: %i[resolve show]

    def index
      @exceptions = Exception.unresolved.order(updated_at: :desc).page(params[:page])
    end

    def show
    end

    def resolve
      @exception.resolve
      redirect_to exceptions_path, notice: t(".success")
    end

    private

    def set_exception
      @exception = Exception.find params[:id]
    end
  end
end
