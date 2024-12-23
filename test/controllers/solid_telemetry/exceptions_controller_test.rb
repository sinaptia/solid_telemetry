require "test_helper"

module SolidTelemetry
  class ExceptionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get exceptions_url
      assert_response :success
    end

    test "should get show" do
      get exception_url(solid_telemetry_exceptions(:unresolved_exception))
      assert_response :success
    end

    test "should resolve an unresolved exception" do
      exception = solid_telemetry_exceptions(:unresolved_exception)

      put resolve_exception_url(exception)
      assert_redirected_to exceptions_url

      assert_not exception.reload.resolved_at.blank?
    end
  end
end
