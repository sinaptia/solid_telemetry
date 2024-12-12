require "opentelemetry-instrumentation-all"

OpenTelemetry::SDK.configure do |config|
  # By default, there's only one service with the name of the app. If you need
  # to distinguish services (eg. background jobs and the rails server), you can
  # set the OTEL_SERVICE_NAME env var for each service and comment the following
  # line, or set a value here.
  config.service_name = Rails.application.name

  # Use all instrumentation
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
    OpenTelemetry::SemanticConventions::Resource::HOST_NAME => Socket.gethostname
  )

  config.add_span_processor OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
    SolidTelemetry::Exporters::ActiveRecord::TraceExporter.new
  )
end
