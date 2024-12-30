module SolidTelemetry
  module Instrumentation
    module ActionPack
      module Handlers
        class ActionController
          # @param config [Hash] of instrumentation options
          def initialize(config)
            @config = config
            @parameter_filter = ActiveSupport::ParameterFilter.new Rails.application.config.filter_parameters

            @allocation_count_start = 0
            @allocation_count_finish = 0
            @gc_time_start = 0
            @gc_time_finish = 0
          end

          # Invoked by ActiveSupport::Notifications at the start of the instrumentation block
          #
          # @param _name [String] of the event (unused)
          # @param _id [String] of the event (unused)
          # @param payload [Hash] the payload passed as a method argument
          def start(_name, _id, payload)
            @allocation_count_start = now_allocations
            @gc_time_start = now_gc
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
            @allocation_count_finish = now_allocations
            @gc_time_finish = now_gc

            span = OpenTelemetry::Instrumentation::Rack.current_span

            env = payload[:request].env

            span.add_attributes({
              "gc.allocations" => allocations,
              "gc.time" => gc_time,
              "rack.session" => @parameter_filter.filter(env["rack.session"].to_h).to_json,
              "action_dispatch.request.parameters" => @parameter_filter.filter(env["action_dispatch.request.parameters"]).to_json
            })
          rescue => e
            OpenTelemetry.handle_error(exception: e)
          end

          private

          # Returns the number of allocations made between the call to #start! and
          # the call to #finish!.
          def allocations
            @allocation_count_finish - @allocation_count_start
          end

          # Returns the time spent in GC (in milliseconds) between the call to #start!
          # and the call to #finish!
          def gc_time
            (@gc_time_finish - @gc_time_start) / 1_000_000.0
          end

          if GC.stat.key?(:total_allocated_objects)
            def now_allocations
              GC.stat(:total_allocated_objects)
            end
          else # Likely on JRuby, TruffleRuby
            def now_allocations
              0
            end
          end

          if GC.respond_to?(:total_time)
            def now_gc
              GC.total_time
            end
          else
            def now_gc
              0
            end
          end
        end
      end
    end
  end
end
