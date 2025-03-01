module SolidTelemetry
  module Metrics
    class BaseMetricReader < OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader
      private

      def meter
        @meter ||= OpenTelemetry.meter_provider.meter Rails.application.name
      end
    end
  end
end
