module SolidTelemetry
  module Metrics
    class ResponseTime < Base
      class P50 < ResponseTime
        name "response_time.p50"
        description "P50"
        unit "ms"
        instrument_kind :up_down_counter

        def measure = super.percentile(:duration, 0.5)
      end

      class P95 < ResponseTime
        name "response_time.p95"
        description "P95"
        unit "ms"
        instrument_kind :up_down_counter

        def measure = super.percentile(:duration, 0.95)
      end

      class P99 < ResponseTime
        name "response_time.p99"
        description "P99"
        unit "ms"
        instrument_kind :up_down_counter

        def measure = super.percentile(:duration, 0.99)
      end

      def measure
        Span.by_host(Host.current.name).roots.rack.where(start_timestamp: 1.minute.ago..)
      end
    end
  end
end
