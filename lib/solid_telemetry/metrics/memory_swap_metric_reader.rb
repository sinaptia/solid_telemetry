module SolidTelemetry
  module Metrics
    class MemorySwapMetricReader < BaseMetricReader
      def collect
        memory_swap_total = Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
        memory_swap = memory_swap_total - Integer(`cat /proc/meminfo | grep SwapFree | grep -E -o '[0-9]+'`)

        counter.add memory_swap

        super
      end

      private

      def counter
        @counter ||= meter.create_up_down_counter "memory_swap", description: "Used swap memory"
      end
    end
  end
end
