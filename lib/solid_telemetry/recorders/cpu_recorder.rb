module SolidTelemetry
  module Recorders
    class CpuRecorder < Base
      def initialize(agent)
        @counter = agent.meter.create_up_down_counter "cpu", description: "CPU usage"
      end

      def capture
        Float `top -bn1 | grep -E '^(%Cpu|CPU)' | awk '{ print $2 + $4 }'`
      end
    end
  end
end
