require "test_helper"

module SolidTelemetry
  class EventTest < ActiveSupport::TestCase
    test "#after_create creates a SolidTelemetry::Exception if the event name is 'exception' and there's no SolidTelemetry::Event for it" do
      assert_changes -> { Exception.count } do
        Event.create(name: "exception", event_attributes: {"exception.type": "NoMethodError", "exception.stacktrace": "doesn't\nmatter"}, span: Span.create(instrumentation_scope: {}))
      end
    end

    test "#after_create updates a SolidTelemetry::Exception if the event name is 'exception' and there's already a SolidTelemetry::Event for it" do
      Event.create(name: "exception", event_attributes: {"exception.type": "NoMethodError", "exception.message": "msg", "exception.stacktrace": "doesn't\nmatter"}, span: Span.create(instrumentation_scope: {}))

      assert_no_changes -> { Exception.count } do
        span = Span.create instrumentation_scope: {}
        Event.create name: "exception", event_attributes: {"exception.type": "NoMethodError", "exception.message": "msg", "exception.stacktrace": "doesn't\nmatter"}, span: span
      end
    end

    test "#after_create creates a SolidTelemetry::Exception if the event name is 'exception' and there's no SolidTelemetry::Event for it with the same fingerprint" do
      Event.create(name: "exception", event_attributes: {"exception.type": "NoMethodError", "exception.stacktrace": "it does\nmatter"}, span: Span.create(instrumentation_scope: {}))

      assert_changes -> { Exception.count } do
        Event.create(name: "exception", event_attributes: {"exception.type": "NoMethodError", "exception.message": "msg", "exception.stacktrace": "doesn't\nmatter"}, span: Span.create(instrumentation_scope: {}))
      end
    end

    test "#after_create unresolves an existing SolidTelemetry::Exception if the event name is 'exception' and there's already a SolidTelemetry::Event for it" do
      resolved_exception_event = solid_telemetry_events(:resolved_exception_event)
      exception = resolved_exception_event.exception

      assert_changes -> { exception.reload.resolved_at }, to: nil do
        resolved_exception_event.dup.save
      end
    end
  end
end
