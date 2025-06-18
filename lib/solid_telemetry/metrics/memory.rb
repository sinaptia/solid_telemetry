module SolidTelemetry
  module Metrics
    class Memory < Base
      class Total < Memory
        name "memory.total"
        description "Total Memory"
        formatter "size"
        instrument_kind :gauge

        def measure
          Integer `cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`
        end
      end

      class Used < Memory
        name "memory.used"
        description "Used memory"
        formatter "size"
        instrument_kind :gauge

        def measure
          memory_total = Integer(`cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`)
          memory_total - Integer(`cat /proc/meminfo | grep MemAvailable | grep -E -o '[0-9]+'`)
        end
      end

      def self.prepare_values(series)
        series.map { |k, v| [k.to_i.in_milliseconds, v&.kilobytes] }
      end
    end
  end
end
