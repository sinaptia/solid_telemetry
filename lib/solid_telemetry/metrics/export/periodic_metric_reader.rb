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
            @counters[metric.name] = meter.send :"create_#{metric.instrument_kind}",  metric.name, description: metric.description
          end
        end

        def collect
          metrics.each do |metric|
            method = metric.instrument_kind == :gauge ? :record : :add
            @counters[metric.name].send method, metric.new.measure
          end

          super
        end

        private

        def meter
          @meter ||= OpenTelemetry.meter_provider.meter Rails.application.name
        end

        def metrics
          SolidTelemetry.metrics.values.flatten
        end
      end
    end
  end
end
