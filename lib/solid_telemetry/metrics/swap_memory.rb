module SolidTelemetry
  module Metrics
    class SwapMemory < Base
      class Total < Memory
        name "swap_memory.total"
        description "Total swap memory"
        formatter "size"
        instrument_kind :gauge

        def measure
          Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
        end
      end

      class Used < Memory
        name "swap_memory.used"
        description "Used swap memory"
        formatter "size"
        instrument_kind :gauge

        def measure
          memory_swap_total = Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
          memory_swap_total - Integer(`cat /proc/meminfo | grep SwapFree | grep -E -o '[0-9]+'`)
        end
      end

      def self.prepare_values(series)
        series.map { |k, v| [k.to_i.in_milliseconds, v&.kilobytes] }
      end
    end
  end
end
