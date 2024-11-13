module SolidTelemetry
  module Recorders
    class MemorySwapRecorder < Base
      def initialize(agent)
        @counter = agent.meter.create_up_down_counter "memory_swap", description: "Used swap memory"
      end

      def capture
        memory_swap_total = Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
        memory_swap_total - Integer(`cat /proc/meminfo | grep SwapFree | grep -E -o '[0-9]+'`)
      end
    end
  end
end
