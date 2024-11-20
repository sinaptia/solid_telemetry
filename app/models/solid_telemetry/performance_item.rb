module SolidTelemetry
  class PerformanceItem < ApplicationRecord
    def error_rate
      error_count = spans.joins(:events).count

      error_count * 100.0 / throughput
    end

    def impact
      total_combined_duration = PerformanceItem.sum :combined_duration

      combined_duration * 100 / total_combined_duration
    end

    def spans
      Span.where name: name
    end
  end
end
