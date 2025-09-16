module SolidTelemetry
  module Metrics
    class ResponseTime < Base
      class P50 < ResponseTime
        name "response_time.p50"
        description "P50"
        unit "ms"

        def self.metric_data(host, time_range, resolution)
          super.percentile :duration, 0.5
        end
      end

      class P95 < ResponseTime
        name "response_time.p95"
        description "P95"
        unit "ms"

        def self.metric_data(host, time_range, resolution)
          super.percentile :duration, 0.95
        end
      end

      class P99 < ResponseTime
        name "response_time.p99"
        description "P99"
        unit "ms"

        def self.metric_data(host, time_range, resolution)
          super.percentile :duration, 0.99
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
