module SolidTelemetry
  module Metrics
    class Throughput < Base
      class Successful < Throughput
        name "throughput.successful"
        description "2xx"
        do_not_record!

        private_class_method def self.data(host, time_range, resolution)
          super.successful.count
        end
      end

      class Redirection < Throughput
        name "throughput.redirection"
        description "3xx"
        do_not_record!

        private_class_method def self.data(host, time_range, resolution)
          super.redirection.count
        end
      end

      class ClientError < Throughput
        name "throughput.client_error"
        description "4xx"
        do_not_record!

        private_class_method def self.data(host, time_range, resolution)
          super.client_error.count
        end
      end

      class ServerError < Throughput
        name "throughput.server_error"
        description "5xx"
        do_not_record!

        private_class_method def self.data(host, time_range, resolution)
          super.server_error.count
        end
      end

      def self.series(host, time_range, resolution)
        prepare_values data(host, time_range, resolution)
      end

      private_class_method def self.data(host, time_range, resolution)
        Span.by_host(host.name).roots.rack.where(start_timestamp: time_range).group_by_minute(:start_timestamp, n: resolution.in_minutes.to_i)
      end
    end
  end
end
