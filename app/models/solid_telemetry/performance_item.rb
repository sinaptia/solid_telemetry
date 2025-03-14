module SolidTelemetry
  class PerformanceItem < ApplicationRecord
    belongs_to :span_name, foreign_key: :solid_telemetry_span_name_id
    has_many :spans, through: :span_name

    after_touch :recalculate_metrics

    delegate :name, to: :span_name

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
