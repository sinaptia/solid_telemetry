module SolidTelemetry
  module Metrics
    class ActiveJobThroughput < Base
      class Failed < ActiveJobThroughput
        name "active_job_throughput.failed"
        description "Failed jobs"
        instrument_kind :up_down_counter

        def measure = super.where.not(total_recorded_events: 0).count
      end

      class Successful < ActiveJobThroughput
        name "active_job_throughput.successful"
        description "Successful jobs"
        instrument_kind :up_down_counter

        def measure = super.where(total_recorded_events: 0).count
      end

      def measure
        Span.by_host(Host.current.name).roots.active_job.where(start_timestamp: 1.minute.ago..)
      end
    end
  end
end
