module SolidTelemetry
  module Metrics
    module Export
      class PeriodicMetricReader < OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader
        attr_reader :counters

        def initialize(export_interval_millis: Float(ENV.fetch('OTEL_METRIC_EXPORT_INTERVAL', 60_000)),
          export_timeout_millis: Float(ENV.fetch('OTEL_METRIC_EXPORT_TIMEOUT', 30_000)),
          exporter: nil)
          super

          @counters = {}

          @counters[:cpu] = create_up_down_counter "cpu.load", description: "CPU usage"
          @counters[:memory_total] = create_up_down_counter "memory.total", description: "Total memory"
          @counters[:memory_used] = create_up_down_counter "memory.used", description: "Used memory"
          @counters[:memory_swap] = create_up_down_counter "memory.swap", description: "Swap memory"
        end

        def collect
          memory_total = Integer(`cat /proc/meminfo | grep MemTotal | grep -E -o '[0-9]+'`)
          memory_used = memory_total - Integer(`cat /proc/meminfo | grep MemAvailable | grep -E -o '[0-9]+'`)
          memory_swap_total = Integer `cat /proc/meminfo | grep SwapTotal | grep -E -o '[0-9]+'`
          memory_swap = memory_swap_total - Integer(`cat /proc/meminfo | grep SwapFree | grep -E -o '[0-9]+'`)

          counters[:cpu].add Float(`top -bn1 | grep -E '^(%Cpu|CPU)' | awk '{ print $2 + $4 }'`)
          counters[:memory_total].add memory_total
          counters[:memory_used].add memory_used
          counters[:memory_swap].add memory_swap

          super
        end

        private

        def create_up_down_counter(name, description:)
          meter.create_up_down_counter name, description: description
        end

        def meter
          @meter ||= OpenTelemetry.meter_provider.meter Rails.application.name
        end
      end
    end
  end
end
