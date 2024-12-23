module SolidTelemetry
  module MetricsHelper
    def has_data?(series)
      series.map { _1[:data] }.flatten.any?
    end

    def resolution_options
      {"1 minute" => 1, "10 minutes" => 10, "1 hour" => 60}
    end
  end
end
