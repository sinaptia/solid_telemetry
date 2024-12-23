require "test_helper"

module SolidTelemetry
  class SpanTest < ActiveSupport::TestCase
    test "#after_create doesn't create a SolidTelemetry::PerformanceItem if the span is not a trace" do
      assert_no_changes -> { PerformanceItem.count } do
        Span.create parent: solid_telemetry_spans(:posts)
      end
    end

    test "#after_create doesn't create a SolidTelemetry::PerformanceItem if the span is a trace and there's already a SolidTelemetry::PerformanceItem for the current trace name" do
      assert_no_changes -> { PerformanceItem.count } do
        solid_telemetry_spans(:posts).dup.save
      end
    end

    test "#after_create doesn't create a SolidTelemetry::PerformanceItem if the span is a trace but the instrumentation scope is not Rack or ActiveJob" do
      assert_no_changes -> { PerformanceItem.count } do
        Span.create name: "TestTrace", duration: 0.5, instrumentation_scope: {name: "OpenTelemetry::Instrumentation::ActiveRecord"}
      end
    end

    test "#after_create creates a SolidTelemetry::PerformanceItem if the span is a trace and there's no SolidTelemetry::PerformanceItem for the current trace name" do
      assert_changes -> { PerformanceItem.count } do
        Span.create name: "TestTrace", duration: 0.5, instrumentation_scope: {name: "OpenTelemetry::Instrumentation::Rack"}
      end
    end
  end
end
