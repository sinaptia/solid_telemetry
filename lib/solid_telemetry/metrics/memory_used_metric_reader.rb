module SolidTelemetry
  module Metrics
    class MemoryUsedMetricReader < BaseMetricReader
      def collect
        memory_total = Integer `cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`
        memory_used = memory_total - Integer(`cat /proc/meminfo | grep MemAvailable | grep -E -o '[0-9]+'`)

        counter.add memory_used

        super
      end

      private

      def counter
        @counter ||= meter.create_up_down_counter "memory_used", description: "Used memory"
      end
    end
  end
end
