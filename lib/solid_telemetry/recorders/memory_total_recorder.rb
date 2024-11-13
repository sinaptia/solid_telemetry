module SolidTelemetry
  module Recorders
    class MemoryTotalRecorder < Base
      def initialize(agent)
        @counter = agent.meter.create_up_down_counter "memory_total", description: "Total memory"
      end

      def capture
        Integer `cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`
      end
    end
  end
end
