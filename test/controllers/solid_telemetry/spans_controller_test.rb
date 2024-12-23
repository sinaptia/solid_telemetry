require "test_helper"

module SolidTelemetry
  class SpansControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get spans_url
      assert_response :success
    end

    test "should get show" do
      get span_url(solid_telemetry_spans(:posts))
      assert_response :success
    end
  end
end
