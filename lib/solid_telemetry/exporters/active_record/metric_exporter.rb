module SolidTelemetry
  module Exporters
    module ActiveRecord
      class MetricExporter < OpenTelemetry::SDK::Metrics::Export::MetricReader
        include Exportable

        def pull
          export collect
        end

        def export(metrics, timeout: nil)
          return SUCCESS unless should_export?

          Rails.logger.silence do
            Array(metrics).each do |metric_data|
              OpenTelemetry::Common::Utilities.untraced do
                metric = Metric.new(
                  name: metric_data.name,
                  description: metric_data.description,
                  unit: metric_data.unit,
                  instrument_kind: metric_data.instrument_kind,
                  resource: metric_data.resource.as_json,
                  instrumentation_scope: metric_data.instrumentation_scope.as_json,
                  data_points: metric_data.data_points.as_json,
                  aggregation_temporality: metric_data.aggregation_temporality,
                  start_time_unix_nano: parse_timestamp(metric_data.start_time_unix_nano),
                  time_unix_nano: parse_timestamp(metric_data.time_unix_nano)
                )

                metric.save!
              end
            end
          end

          SUCCESS
        end
      end
    end
  end
end
