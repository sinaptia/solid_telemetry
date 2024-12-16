module SolidTelemetry
  module Instrumentation
    module ActionPack
      module Handlers
        class ActionController
          # @param config [Hash] of instrumentation options
          def initialize(config)
            @config = config
            @parameter_filter = ActiveSupport::ParameterFilter.new Rails.application.config.filter_parameters
          end

          # Invoked by ActiveSupport::Notifications at the start of the instrumentation block
          #
          # @param _name [String] of the event (unused)
          # @param _id [String] of the event (unused)
          # @param payload [Hash] the payload passed as a method argument
          def start(_name, _id, payload)
          rescue => e
            OpenTelemetry.handle_error(exception: e)
          end

          # Invoked by ActiveSupport::Notifications at the end of the instrumentation block
          #
          # @param _name [String] of the event (unused)
          # @param _id [String] of the event (unused)
          # @param payload [Hash] the payload passed as a method argument
          # @return [Hash] the payload passed as a method argument
          def finish(_name, _id, payload)
            span = OpenTelemetry::Instrumentation::Rack.current_span

            env = payload[:request].env

            span.add_attributes({
              "rack.session" => @parameter_filter.filter(env["rack.session"].to_h).to_json,
              "action_dispatch.request.parameters" => @parameter_filter.filter(env["action_dispatch.request.parameters"]).to_json
            })
          rescue => e
            OpenTelemetry.handle_error(exception: e)
          end
        end
      end
    end
  end
end
