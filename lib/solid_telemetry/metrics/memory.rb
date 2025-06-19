module SolidTelemetry
  module Metrics
    class Memory < Base
      class Total < Memory
        name "memory.total"
        description "Total Memory"
        unit "size"
        instrument_kind :gauge

        def measure
          Integer `cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`
        end
      end

      class Used < Memory
        name "memory.used"
        description "Used memory"
        unit "size"
        instrument_kind :gauge

        def measure
          memory_total = Integer(`cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`)
          memory_total - Integer(`cat /proc/meminfo | grep MemAvailable | grep -E -o '[0-9]+'`)
        end
      end
    end
  end
end
