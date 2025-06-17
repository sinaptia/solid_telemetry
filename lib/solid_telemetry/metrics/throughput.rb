module SolidTelemetry
  module Metrics
    class Throughput < Base
      class Successful < Throughput
        name "throughput.successful"
        description "2xx"
        instrument_kind :up_down_counter

        def measure = super.successful.count
      end

      class Redirection < Throughput
        name "throughput.redirection"
        description "3xx"
        instrument_kind :up_down_counter

        def measure = super.redirection.count
      end

      class ClientError < Throughput
        name "throughput.client_error"
        description "4xx"
        instrument_kind :up_down_counter

        def measure = super.client_error.count
      end

      class ServerError < Throughput
        name "throughput.server_error"
        description "5xx"
        instrument_kind :up_down_counter

        def measure = super.server_error.count
      end

      def measure
        Span.by_host(Host.current.name).roots.rack.where(start_timestamp: 1.minute.ago..)
      end
    end
  end
end
