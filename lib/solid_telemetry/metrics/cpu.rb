module SolidTelemetry
  module Metrics
    class Cpu < Base
      name "cpu.load"
      description "CPU usage"

      def self.formatter = "percentage"

      def record
        Float `top -bn1 | grep -E '^(%Cpu|CPU)' | awk '{ print $2 + $4 }'`
      end
    end
  end
end
