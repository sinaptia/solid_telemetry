module SolidTelemetry
  class Host < ApplicationRecord
    def self.current
      find_by name: Socket.gethostname
    end

    def self.register
      find_or_create_by name: Socket.gethostname
    end
  end
end
