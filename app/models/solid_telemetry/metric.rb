module SolidTelemetry
  class Metric < ApplicationRecord
    include HostScoped
  end
end
