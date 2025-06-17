module SolidTelemetry
  module Metrics
    class Cpu < Base
      name "cpu.load"
      description "CPU usage"
      formatter "percentage"
      instrument_kind :gauge

      def measure
        Float `top -bn1 | grep -E '^(%Cpu|CPU)' | awk '{ print $2 + $4 }'`
      end
    end
  end
end
