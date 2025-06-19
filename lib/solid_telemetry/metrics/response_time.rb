module SolidTelemetry
  module Metrics
    class ResponseTime < Base::Span
      class P50 < ResponseTime
        name "response_time.p50"
        description "P50"
        unit "ms"

        def self.span_data(host, time_range, resolution)
          super.rack.percentile :duration, 0.5
        end
      end

      class P95 < ResponseTime
        name "response_time.p95"
        description "P95"
        unit "ms"

        def self.span_data(host, time_range, resolution)
          super.rack.percentile :duration, 0.95
        end
      end

      class P99 < ResponseTime
        name "response_time.p99"
        description "P99"
        unit "ms"

        def self.span_data(host, time_range, resolution)
          super.rack.percentile :duration, 0.99
        end
      end
    end
  end
end
