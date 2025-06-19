module SolidTelemetry
  module Metrics
    class ActiveJobThroughput < Base::Span
      class Failed < ActiveJobThroughput
        name "active_job_throughput.failed"
        description "Failed jobs"

        def self.span_data(host, time_range, resolution)
          super.active_job.where.not(total_recorded_events: 0).count
        end
      end

      class Successful < ActiveJobThroughput
        name "active_job_throughput.successful"
        description "Successful jobs"

        def self.span_data(host, time_range, resolution)
          super.active_job.where(total_recorded_events: 0).count
        end
      end
    end
  end
end
