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

        def do_not_record!
          @record = false
        end

        def formatter = nil

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

        def record?
          @record != false
        end

        def series(host, time_range, resolution)
          prepare_values Metric.by_host(host.name).where(name: name).group_by_minute(:time_unix_nano, range: time_range, n: resolution.in_minutes.to_i).maximum(:value)
        end
      end

      def record = raise NotImplementedError
    end
  end
end
