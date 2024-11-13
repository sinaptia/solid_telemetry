require "test_helper"

module SolidTelemetry
  class MetricsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get metrics_url
      assert_response :success
    end
  end
end
