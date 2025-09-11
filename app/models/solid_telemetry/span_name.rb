module SolidTelemetry
  class SpanName < ApplicationRecord
    has_many :performance_items, foreign_key: :solid_telemetry_span_name_id
    has_many :spans, foreign_key: :solid_telemetry_span_name_id

    validates :name, presence: true, uniqueness: true

    scope :roots, -> { where root: true }

    def error_rate(time_range) = spans.where(start_timestamp: time_range).joins(:events).count * 100 / throughput(time_range)

    def impact_score(time_range) = (throughput(time_range) * p100_duration(time_range)) / 1000

    # p50_duration
    # p95_duration
    # p99_duration
    # p100_duration
    [50, 95, 99, 100].each do |n|
      define_method(:"p#{n}_duration") { |time_range| spans.where(start_timestamp: time_range).percentile(:duration, n / 100.0) }
    end

    def throughput(time_range) = spans.where(start_timestamp: time_range).count
  end
end
