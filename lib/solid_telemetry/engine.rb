module SolidTelemetry
  class Engine < ::Rails::Engine
    isolate_namespace SolidTelemetry

    config.solid_telemetry = ActiveSupport::OrderedOptions.new

    initializer "solid_telemetry.config" do
      config.solid_telemetry.each do |name, value|
        SolidTelemetry.public_send(:"#{name}=", value)
      end
    end

    initializer "solid_telemetry.assets" do |app|
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.precompile += %w[solid_telemetry_manifest]
    end

    initializer "solid_telemetry.importmap", after: "importmap" do |app|
      SolidTelemetry.importmap.draw(root.join("config/importmap.rb"))
      SolidTelemetry.importmap.cache_sweeper(watches: root.join("app/javascript"))

      ActiveSupport.on_load(:action_controller_base) do
        before_action { SolidTelemetry.importmap.cache_sweeper.execute_if_updated }
      end
    end

    config.after_initialize do
      exporter = SolidTelemetry::Exporters::ActiveRecord::MetricExporter.new

      [Metrics::CpuMetricReader, Metrics::MemoryTotalMetricReader, Metrics::MemoryUsedMetricReader, Metrics::MemorySwapMetricReader].each do |klass|
        reader = klass.new exporter: exporter
        OpenTelemetry.meter_provider.add_metric_reader reader
      end

      OpenTelemetry::Common::Utilities.untraced do
        Host.register if SolidTelemetry.enabled?
      end
    end
  end
end
