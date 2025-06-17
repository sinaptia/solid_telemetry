module SolidTelemetry
  module Metrics
    class Memory < Base
      class Swap < Memory
        name "memory.swap"
        description "Swap memory"

        def measure
          memory_swap_total = Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
          memory_swap_total - Integer(`cat /proc/meminfo | grep SwapFree | grep -E -o '[0-9]+'`)
        end
      end

      class Total < Memory
        name "memory.total"
        description "Total Memory"

        def measure
          Integer `cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`
        end
      end

      class Used < Memory
        name "memory.used"
        description "Used memory"

        def measure
          memory_total = Integer(`cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`)
          memory_total - Integer(`cat /proc/meminfo | grep MemAvailable | grep -E -o '[0-9]+'`)
        end
      end

      formatter "size"
      instrument_kind :gauge

      def prepare_values(series)
        series.map { |k, v| [k.to_i.in_milliseconds, v&.kilobytes] }
      end
    end
  end
end
