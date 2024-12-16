require_relative "handlers/action_controller"

module SolidTelemetry
  module Instrumentation
    module ActionPack
      module Handlers
        module_function

        def subscribe
          return unless Array(@subscriptions).empty?

          config = ActionPack::Instrumentation.instance.config
          handlers_by_pattern = {
            "process_action.action_controller" => Handlers::ActionController.new(config)
          }

          @subscriptions = handlers_by_pattern.map do |key, handler|
            ::ActiveSupport::Notifications.subscribe(key, handler)
          end
        end

        def unsubscribe
          @subscriptions&.each { |subscriber| ::ActiveSupport::Notifications.unsubscribe(subscriber) }
          @subscriptions = nil
        end
      end
    end
  end
end
