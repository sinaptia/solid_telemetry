require "kaminari"

module SolidTelemetry
  class ApplicationController < SolidTelemetry.base_controller_class.constantize
    private

    def filter_param
      {}
    end
    helper_method :filter_param
  end
end
