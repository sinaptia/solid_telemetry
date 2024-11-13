module SolidTelemetry
  module Exporters
    module ActiveRecord
      module Exportable
        extend ActiveSupport::Concern

        SUCCESS = OpenTelemetry::SDK::Trace::Export::SUCCESS
        FAILURE = OpenTelemetry::SDK::Trace::Export::FAILURE

        private_constant :SUCCESS, :FAILURE

        def force_flush(timeout: nil)
          SUCCESS
        end

        def shutdown(timeout: nil)
          SUCCESS
        end

        private

        def parse_hex_id(id)
          parsed_id = id.unpack1("H*")
          (parsed_id == "0000000000000000") ? nil : parsed_id
        end

        def parse_timestamp(timestamp)
          Time.at(timestamp.to_i / 1000000000.0)
        end

        def should_export?
          defined? Rails::Server
        end
      end
    end
  end
end
