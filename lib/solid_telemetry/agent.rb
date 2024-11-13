module SolidTelemetry
  class Agent
    attr_reader :meter, :recorders

    def initialize
      exporter = SolidTelemetry::Exporters::ActiveRecord::MetricExporter.new
      OpenTelemetry.meter_provider.add_metric_reader exporter

      @meter = OpenTelemetry.meter_provider.meter Rails.application.name
      @recorders = []
    end

    def start
      Thread.new do
        loop do
          recorders.each(&:record)

          OpenTelemetry.meter_provider.metric_readers.each(&:pull)
        rescue
          Rails.logger.info "[SolidTelemetry::Agent] something's wrong: #{$!}"
        ensure
          sleep SolidTelemetry.agent_interval
        end
      end
    end
  end
end
