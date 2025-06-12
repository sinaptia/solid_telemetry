SolidTelemetry.configure do |config|
  # controller base class
  # config.base_controller_class = AdminController

  config.metrics = {
    cpu: [
      SolidTelemetry::Metrics::Cpu
    ],
    memory: [
      SolidTelemetry::Metrics::Memory::Total,
      SolidTelemetry::Metrics::Memory::Used,
      SolidTelemetry::Metrics::Memory::Swap
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
end
