module SolidTelemetry
  module Metrics
    class ActiveJobThroughput < Base
      class Failed < ActiveJobThroughput
        name "active_job_throughput.failed"
        description "Failed jobs"
        do_not_record!

        private_class_method def self.data(host, time_range, resolution)
          super.where.not(total_recorded_events: 0).count
        end
      end

      class Successful < ActiveJobThroughput
        name "active_job_throughput.successful"
        description "Successful jobs"
        do_not_record!

        private_class_method def self.data(host, time_range, resolution)
          super.where(total_recorded_events: 0).count
        end
      end

      def self.series(host, time_range, resolution)
        prepare_values data(host, time_range, resolution)
      end

      private_class_method def self.data(host, time_range, resolution)
        Span.by_host(host.name).roots.active_job.where(start_timestamp: time_range).group_by_minute(:start_timestamp, n: resolution.in_minutes.to_i)
      end
    end
  end
end
