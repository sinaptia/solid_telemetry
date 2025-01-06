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

  autoload :Agent, "solid_telemetry/agent"

  module Exporters
    module ActiveRecord
      autoload :Exportable, "solid_telemetry/exporters/active_record/exportable"
      autoload :MetricExporter, "solid_telemetry/exporters/active_record/metric_exporter"
      autoload :TraceExporter, "solid_telemetry/exporters/active_record/trace_exporter"
    end
  end

  module Recorders
    autoload :Base, "solid_telemetry/recorders/base"
    autoload :CpuRecorder, "solid_telemetry/recorders/cpu_recorder"
    autoload :MemorySwapRecorder, "solid_telemetry/recorders/memory_swap_recorder"
    autoload :MemoryTotalRecorder, "solid_telemetry/recorders/memory_total_recorder"
    autoload :MemoryUsedRecorder, "solid_telemetry/recorders/memory_used_recorder"
  end

  config_accessor :agent_interval, default: 1.minute
  config_accessor :base_controller_class, default: "ApplicationController"
  config_accessor :connects_to
  config_accessor :importmap, default: Importmap::Map.new

  def self.enabled?
    !defined?(Rails::Console) && (!defined?(Rails::Command) || defined?(Rails::Server))
  end
end
