module SolidTelemetry
  module HostScoped
    extend ActiveSupport::Concern

    included do
      scope :by_host, ->(hostname) { where hostname: hostname }
    end
  end
end
