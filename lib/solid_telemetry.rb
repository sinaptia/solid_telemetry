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
  end

  config_accessor :base_controller_class, default: "ApplicationController"
  config_accessor :connects_to
  config_accessor :importmap, default: Importmap::Map.new

  def self.enabled?
    !defined?(Rails::Console) && (!defined?(Rails::Command) || defined?(Rails::Server))
  end
end
