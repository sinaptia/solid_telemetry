require "opentelemetry-instrumentation-all"

OpenTelemetry::SDK.configure do |config|
  config.service_name = Rails.application.name
  # enable all instrumentation
  config.use_all(
    "OpenTelemetry::Instrumentation::ActiveJob" => {
      span_naming: :job_class
    },
    "OpenTelemetry::Instrumentation::ActionPack" => {
      span_naming: :class
    },
    "OpenTelemetry::Instrumentation::Rack" => {
      # we don't want traces coming out of solid_telemetry's controllers
      # if you mount the engine other than /telemetry, make sure you update this block
      untraced_requests: ->(env) {
        env["PATH_INFO"].starts_with?("/telemetry")
      }
    }
  )

  config.resource = OpenTelemetry::SDK::Resources::Resource.create(
    OpenTelemetry::SemanticConventions::Resource::HOST_NAME => `hostname`.chomp
  )

  config.add_span_processor OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
    SolidTelemetry::Exporters::ActiveRecord::TraceExporter.new
  )
end
