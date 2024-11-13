require "test_helper"

module SolidTelemetry
  class ExceptionsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get exceptions_url
      assert_response :success
    end

    test "should get show" do
      get exception_url(solid_telemetry_exceptions(:exception_1))
      assert_response :success
    end
  end
end
