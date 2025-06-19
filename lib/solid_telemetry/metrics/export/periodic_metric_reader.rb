module SolidTelemetry
  module Metrics
    module Export
      class PeriodicMetricReader < OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader
        def initialize(export_interval_millis: Float(ENV.fetch("OTEL_METRIC_EXPORT_INTERVAL", 60_000)),
          export_timeout_millis: Float(ENV.fetch("OTEL_METRIC_EXPORT_TIMEOUT", 30_000)),
          exporter: nil)
          super

          @instruments = {}

          metrics.each do |metric|
            @instruments[metric.name] = meter.send :"create_#{metric.instrument_kind}", metric.name, description: metric.description, unit: metric.unit
          end
        end

        def collect
          metrics.each do |metric|
            method = [:counter, :up_down_counter].include?(metric.instrument_kind) ? :add : :record
            @instruments[metric.name].send method, metric.new.measure
          end

          super
        end

        private

        def meter
          @meter ||= OpenTelemetry.meter_provider.meter Rails.application.name
        end

        def metrics
          SolidTelemetry.metrics.values.flatten.select { |metric| metric.instrument_kind.present? }
        end
      end
    end
  end
end
