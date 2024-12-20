require "opentelemetry/instrumentation/base"

module SolidTelemetry
  module Instrumentation
    module ActionPack
      class Instrumentation < OpenTelemetry::Instrumentation::Base
        MINIMUM_VERSION = Gem::Version.new("7.2.0")

        install do |_config|
          require_dependencies
          patch
        end

        present do
          defined?(::ActionController)
        end

        compatible do
          gem_version >= MINIMUM_VERSION
        end

        private

        def gem_version
          ::ActionPack.version
        end

        def patch
          Handlers.subscribe
        end

        def require_dependencies
          require_relative "handlers"
        end
      end
    end
  end
end
