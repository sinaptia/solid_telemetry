module SolidTelemetry
  module Metrics
    class Base
      class << self
        def description(description = nil)
          @description = description if description.present?
          @description
        end

        def formatter(formatter = nil)
          @formatter = formatter if formatter.present?
          @formatter
        end

        def instrument_kind(instrument_kind = nil)
          @instrument_kind = instrument_kind if instrument_kind.present?
          @instrument_kind || :gauge
        end

        def name(name = nil)
          @name = name if name.present?
          @name
        end

        def prepare_values(series)
          series.map { |k, v| [k.to_i.in_milliseconds, v] }
        end

        def series(host, time_range, resolution)
          prepare_values Metric.by_host(host.name).where(name: name).group_by_minute(:time_unix_nano, range: time_range, n: resolution.in_minutes.to_i).maximum(:value)
        end
      end

      def measure = raise NotImplementedError
    end
  end
end
