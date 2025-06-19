SolidTelemetry.configure do |config|
  # == Controller base class
  # Configure the base class for all solid telemetry controllers.
  # config.base_controller_class = AdminController

  # == Metrics
  # Configure the metrics that will be displayed in /telemetry/metrics
  # This is the default hash. Keys represents charts, and values (arrays) represent metrics.
  # config.metrics = {
  #   cpu: [
  #     SolidTelemetry::Metrics::Cpu
  #   ],
  #   memory: [
  #     SolidTelemetry::Metrics::Memory::Total,
  #     SolidTelemetry::Metrics::Memory::Used,
  #     SolidTelemetry::Metrics::SwapMemory::Total,
  #     SolidTelemetry::Metrics::SwapMemory::Used
  #   ],
  #   response_time: [
  #     SolidTelemetry::Metrics::ResponseTime::P50,
  #     SolidTelemetry::Metrics::ResponseTime::P95,
  #     SolidTelemetry::Metrics::ResponseTime::P99
  #   ],
  #   throughput: [
  #     SolidTelemetry::Metrics::Throughput::Successful,
  #     SolidTelemetry::Metrics::Throughput::Redirection,
  #     SolidTelemetry::Metrics::Throughput::ClientError,
  #     SolidTelemetry::Metrics::Throughput::ServerError
  #   ],
  #   active_job_throughput: [
  #     SolidTelemetry::Metrics::ActiveJobThroughput::Successful,
  #     SolidTelemetry::Metrics::ActiveJobThroughput::Failed
  #   ]
  # }
end
