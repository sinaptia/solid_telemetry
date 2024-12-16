module SolidTelemetry
  module Exporters
    module ActiveRecord
      module Exportable
        extend ActiveSupport::Concern

        SUCCESS = OpenTelemetry::SDK::Trace::Export::SUCCESS
        FAILURE = OpenTelemetry::SDK::Trace::Export::FAILURE

        private_constant :SUCCESS, :FAILURE

        def force_flush(timeout:)
          SUCCESS
        end

        def shutdown(timeout:)
          SUCCESS
        end

        private

        def parse_timestamp(timestamp)
          Time.at(timestamp.to_i / 1000000000.0)
        end
      end
    end
  end
end
