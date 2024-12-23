require "test_helper"

module SolidTelemetry
  class ExceptionTest < ActiveSupport::TestCase
    test "#resolve sets the resolved_at field to the current time" do
      exception = solid_telemetry_exceptions(:unresolved_exception)

      assert_changes -> { exception.resolved_at } do
        exception.resolve
      end

      assert_not exception.resolved_at.blank?
    end
  end
end
