module SolidTelemetry
  module Metrics
    class Throughput < Base
      class Successful < Throughput
        name "throughput.successful"
        description "2xx"

        def self.metric_data(host, time_range, resolution)
          super.successful.count
        end
      end

      class Redirection < Throughput
        name "throughput.redirection"
        description "3xx"

        def self.metric_data(host, time_range, resolution)
          super.redirection.count
        end
      end

      class ClientError < Throughput
        name "throughput.client_error"
        description "4xx"

        def self.metric_data(host, time_range, resolution)
          super.client_error.count
        end
      end

      class ServerError < Throughput
        name "throughput.server_error"
        description "5xx"

        def self.metric_data(host, time_range, resolution)
          super.server_error.count
        end
      end

      def self.metric_data(host_or_span_name, time_range, resolution)
        collection = if host_or_span_name.is_a? Host
          Span.by_host(host_or_span_name.name)
        elsif host_or_span_name.is_a? SpanName
          Span.where(span_name: host_or_span_name)
        end

        collection.roots.rack.where(start_timestamp: time_range).group_by_minute(:start_timestamp, n: resolution.in_minutes.to_i)
      end
    end
  end
end
