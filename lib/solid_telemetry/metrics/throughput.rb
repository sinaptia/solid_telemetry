module SolidTelemetry
  module Metrics
    class Throughput < Base::Span
      class Successful < Throughput
        name "throughput.successful"
        description "2xx"

        def self.span_data(host, time_range, resolution)
          super.rack.successful.count
        end
      end

      class Redirection < Throughput
        name "throughput.redirection"
        description "3xx"

        def self.span_data(host, time_range, resolution)
          super.rack.redirection.count
        end
      end

      class ClientError < Throughput
        name "throughput.client_error"
        description "4xx"

        def self.span_data(host, time_range, resolution)
          super.rack.client_error.count
        end
      end

      class ServerError < Throughput
        name "throughput.server_error"
        description "5xx"

        def self.span_data(host, time_range, resolution)
          super.rack.server_error.count
        end
      end
    end
  end
end
