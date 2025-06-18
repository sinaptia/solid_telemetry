module SolidTelemetry
  module Metrics
    class SwapMemory < Base
      class Total < Memory
        name "swap_memory.total"
        description "Total swap memory"
        unit "size"
        instrument_kind :gauge

        def measure
          Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
        end
      end

      class Used < Memory
        name "swap_memory.used"
        description "Used swap memory"
        unit "size"
        instrument_kind :gauge

        def measure
          memory_swap_total = Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
          memory_swap_total - Integer(`cat /proc/meminfo | grep SwapFree | grep -E -o '[0-9]+'`)
        end
      end
    end
  end
end
