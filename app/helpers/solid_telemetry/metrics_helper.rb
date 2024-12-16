module SolidTelemetry
  module MetricsHelper
    def has_data?(series)
      series.map { _1[:data] }.flatten.any?
    end
  end
end
