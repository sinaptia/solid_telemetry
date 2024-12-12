module SolidTelemetry
  class Host < ApplicationRecord
    def self.register
      find_or_create_by name: Socket.gethostname
    end
  end
end
