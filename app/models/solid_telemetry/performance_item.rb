module SolidTelemetry
  class PerformanceItem < ApplicationRecord
    has_many :spans, foreign_key: :name, primary_key: :name

    after_touch :recalculate_metrics

    private

    def recalculate_metrics
      p50_duration = spans.percentile :duration, 0.5
      p95_duration = spans.percentile :duration, 0.95
      p99_duration = spans.percentile :duration, 0.99
      p100_duration = spans.percentile :duration, 1

      throughput = spans.count
      impact_score = (throughput * p100_duration) / 1000

      error_rate = spans.joins(:events).count * 100 / throughput

      update(
        throughput: throughput,
        p50_duration: p50_duration,
        p95_duration: p95_duration,
        p99_duration: p99_duration,
        impact_score: impact_score,
        error_rate: error_rate
      )
    end
  end
end
