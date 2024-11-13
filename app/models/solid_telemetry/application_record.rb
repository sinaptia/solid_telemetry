module SolidTelemetry
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to(**SolidTelemetry.connects_to) if SolidTelemetry.connects_to
  end
end
