require "opentelemetry-instrumentation-all"
require "solid_telemetry/instrumentation/action_pack"

# Extracted from rack: Rack::Headers::KNOWN_HEADERS. Unfortunately, Rails 7.2
# supports rack >= 2.2.4, which doesn't define Rack::Headers::KNOWN_HEADERS.
KNOWN_HEADERS = %w[
  Accept-CH
  Accept-Patch
  Accept-Ranges
  Access-Control-Allow-Credentials
  Access-Control-Allow-Headers
  Access-Control-Allow-Methods
  Access-Control-Allow-Origin
  Access-Control-Expose-Headers
  Access-Control-Max-Age
  Age
  Allow
  Alt-Svc
  Cache-Control
  Connection
  Content-Disposition
  Content-Encoding
  Content-Language
  Content-Length
  Content-Location
  Content-MD5
  Content-Range
  Content-Security-Policy
  Content-Security-Policy-Report-Only
  Content-Type
  Date
  Delta-Base
  ETag
  Expect-CT
  Expires
  Feature-Policy
  IM
  Last-Modified
  Link
  Location
  NEL
  P3P
  Permissions-Policy
  Pragma
  Preference-Applied
  Proxy-Authenticate
  Public-Key-Pins
  Referrer-Policy
  Refresh
  Report-To
  Retry-After
  Server
  Set-Cookie
  Status
  Strict-Transport-Security
  Timing-Allow-Origin
  Tk
  Trailer
  Transfer-Encoding
  Upgrade
  Vary
  Via
  WWW-Authenticate
  Warning
  X-Cascade
  X-Content-Duration
  X-Content-Security-Policy
  X-Content-Type-Options
  X-Correlation-ID
  X-Correlation-Id
  X-Download-Options
  X-Frame-Options
  X-Permitted-Cross-Domain-Policies
  X-Powered-By
  X-Redirect-By
  X-Request-ID
  X-Request-Id
  X-Runtime
  X-UA-Compatible
  X-WebKit-CS
  X-XSS-Protection
]

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
      allowed_request_headers: KNOWN_HEADERS,
      allowed_response_headers: KNOWN_HEADERS,
      # we don't want traces coming out of solid_telemetry's controllers
      # if you mount the engine other than /telemetry, make sure you update this block
      untraced_requests: ->(env) {
        env["PATH_INFO"].starts_with?("/telemetry")
      }
    },
    # Custom ActionPack instrumentation:
    "SolidTelemetry::Instrumentation::ActionPack" => {}
  )

  config.resource = OpenTelemetry::SDK::Resources::Resource.create(
    OpenTelemetry::SemanticConventions::Resource::HOST_NAME => Socket.gethostname,
    OpenTelemetry::SemanticConventions::Resource::SERVICE_NAME => ENV.fetch("OTEL_SERVICE_NAME", "unknown_service")
  )

  config.add_span_processor OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
    SolidTelemetry::Exporters::ActiveRecord::TraceExporter.new
  )
end
