module SolidTelemetry
  module Metrics
    class Base
      class << self
        def description(description = nil)
          @description = description if description.present?
          @description
        end

        def unit(unit = nil)
          @unit = unit if unit.present?
          @unit
        end

        def instrument_kind(instrument_kind = nil)
          @instrument_kind = instrument_kind if instrument_kind.present?
          @instrument_kind
        end

        def metric_data(host, time_range, resolution)
          calculation = [:gauge, :histogram].include?(instrument_kind) ? :maximum : :sum

          Metric.by_host(host.name).where(name: name).group_by_minute(:time_unix_nano, range: time_range, n: resolution.in_minutes.to_i).send(calculation, :value)
        end

        def name(name = nil)
          @name = name if name.present?
          @name
        end

        def serialize_values(series)
          case unit
          when "size"
            series.map { |k, v| [k.to_i.in_milliseconds, v&.kilobytes] }
          else
            series.map { |k, v| [k.to_i.in_milliseconds, v.to_f] }
          end
        end

        def series(host, time_range, resolution)
          serialize_values metric_data(host, time_range, resolution)
        end
      end
    end
  end
end
