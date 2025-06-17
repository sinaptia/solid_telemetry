module SolidTelemetry
  module Metrics
    class ResponseTime < Base
      class P50 < ResponseTime
        name "response_time.p50"
        description "P50"
        formatter "ms"
        instrument_kind :up_down_counter

        def measure = super.percentile(:duration, 0.5)
      end

      class P95 < ResponseTime
        name "response_time.p95"
        description "P95"
        formatter "ms"
        instrument_kind :up_down_counter

        def measure = super.percentile(:duration, 0.95)
      end

      class P99 < ResponseTime
        name "response_time.p99"
        description "P99"
        formatter "ms"
        instrument_kind :up_down_counter

        def measure = super.percentile(:duration, 0.99)
      end

      def self.prepare_values(series)
        series.map { |k, v| [k.to_i.in_milliseconds, v.to_f] }
      end

      def measure
        Span.by_host(Host.current.name).roots.rack.where(start_timestamp: 1.minute.ago..)
      end
    end
  end
end
