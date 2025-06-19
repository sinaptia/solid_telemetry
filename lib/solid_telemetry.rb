require "active_median"
require "importmap-rails"
require "groupdate"
require "opentelemetry-metrics-sdk"
require "opentelemetry-sdk"
require "with_recursive_tree"

require "solid_telemetry/version"
require "solid_telemetry/engine"

module SolidTelemetry
  include ActiveSupport::Configurable

  module Exporters
    module ActiveRecord
      autoload :Exportable, "solid_telemetry/exporters/active_record/exportable"
      autoload :MetricExporter, "solid_telemetry/exporters/active_record/metric_exporter"
      autoload :TraceExporter, "solid_telemetry/exporters/active_record/trace_exporter"
    end
  end

  module Metrics
    module Export
      autoload :PeriodicMetricReader, "solid_telemetry/metrics/export/periodic_metric_reader"
    end

    autoload :ActiveJobThroughput, "solid_telemetry/metrics/active_job_throughput"
    autoload :Base, "solid_telemetry/metrics/base"
    autoload :Cpu, "solid_telemetry/metrics/cpu"
    autoload :Memory, "solid_telemetry/metrics/memory"
    autoload :ResponseTime, "solid_telemetry/metrics/response_time"
    autoload :SwapMemory, "solid_telemetry/metrics/swap_memory"
    autoload :Throughput, "solid_telemetry/metrics/throughput"
  end

  config_accessor :base_controller_class, default: "ApplicationController"
  config_accessor :connects_to
  config_accessor :importmap, default: Importmap::Map.new
  config_accessor :metrics, default: {
    cpu: [
      SolidTelemetry::Metrics::Cpu
    ],
    memory: [
      SolidTelemetry::Metrics::Memory::Total,
      SolidTelemetry::Metrics::Memory::Used,
      SolidTelemetry::Metrics::SwapMemory::Total,
      SolidTelemetry::Metrics::SwapMemory::Used
    ],
    response_time: [
      SolidTelemetry::Metrics::ResponseTime::P50,
      SolidTelemetry::Metrics::ResponseTime::P95,
      SolidTelemetry::Metrics::ResponseTime::P99
    ],
    throughput: [
      SolidTelemetry::Metrics::Throughput::Successful,
      SolidTelemetry::Metrics::Throughput::Redirection,
      SolidTelemetry::Metrics::Throughput::ClientError,
      SolidTelemetry::Metrics::Throughput::ServerError
    ],
    active_job_throughput: [
      SolidTelemetry::Metrics::ActiveJobThroughput::Successful,
      SolidTelemetry::Metrics::ActiveJobThroughput::Failed
    ]
  }

  def self.enabled?
    !defined?(Rails::Console) && (!defined?(Rails::Command) || defined?(Rails::Server))
  end
end
