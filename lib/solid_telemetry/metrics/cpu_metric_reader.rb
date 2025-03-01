module SolidTelemetry
  module Metrics
    class CpuMetricReader < BaseMetricReader
      def collect
        counter.add Float(`top -bn1 | grep -E '^(%Cpu|CPU)' | awk '{ print $2 + $4 }'`)

        super
      end

      private

      def counter
        @counter ||= meter.create_up_down_counter "cpu", description: "CPU usage"
      end
    end
  end
end
