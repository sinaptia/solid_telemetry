module SolidTelemetry
  module Recorders
    class MemoryUsedRecorder < Base
      def initialize(agent)
        @counter = agent.meter.create_up_down_counter "memory_used", description: "Used memory"
      end

      def capture
        memory_total = Integer `cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`
        memory_total - Integer(`cat /proc/meminfo | grep MemAvailable | grep -E -o '[0-9]+'`)
      end
    end
  end
end
