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
      OpenTelemetry.meter_provider = OpenTelemetry::SDK::Metrics::MeterProvider.new

      agent = Agent.new

      agent.recorders << Recorders::CpuRecorder.new(agent)
      agent.recorders << Recorders::MemoryTotalRecorder.new(agent)
      agent.recorders << Recorders::MemoryUsedRecorder.new(agent)
      agent.recorders << Recorders::MemorySwapRecorder.new(agent)

      agent.start
    end
  end
end
