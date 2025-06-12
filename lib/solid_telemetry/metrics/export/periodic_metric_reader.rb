module SolidTelemetry
  module Metrics
    module Export
      class PeriodicMetricReader < OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader
        attr_reader :counters

        def initialize(export_interval_millis: Float(ENV.fetch("OTEL_METRIC_EXPORT_INTERVAL", 60_000)),
          export_timeout_millis: Float(ENV.fetch("OTEL_METRIC_EXPORT_TIMEOUT", 30_000)),
          exporter: nil)
          super

          @counters = {}

          metrics.each do |metric|
            @counters[metric.name] = meter.create_up_down_counter metric.name, description: metric.description
          end
        end

        def collect
          metrics.each do |metric|
            @counters[metric.name].add metric.new.record
          end

          super
        end

        private

        def meter
          @meter ||= OpenTelemetry.meter_provider.meter Rails.application.name
        end

        def metrics
          SolidTelemetry.metrics.values.flatten.select { |metric| metric.record? }
        end
      end
    end
  end
end
