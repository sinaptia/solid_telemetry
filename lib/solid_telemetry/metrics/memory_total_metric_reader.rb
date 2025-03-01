module SolidTelemetry
  module Metrics
    class MemoryTotalMetricReader < BaseMetricReader
      def collect
        counter.add Integer(`cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`)

        super
      end

      private

      def counter
        @counter ||= meter.create_up_down_counter "memory_total", description: "Total memory"
      end
    end
  end
end
