module SolidTelemetry
  module Metrics
    class Base
      class << self
        def description(description = nil)
          if description.present?
            @description = description
          else
            @description
          end
        end

        def formatter(formatter = nil)
          if formatter.present?
            @formatter = formatter
          else
            @formatter
          end
        end

        def instrument_kind(instrument_kind = nil)
          if instrument_kind.present?
            @instrument_kind = instrument_kind
          else
            @instrument_kind || :gauge
          end
        end

        def name(name = nil)
          if name.present?
            @name = name
          else
            @name
          end
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
