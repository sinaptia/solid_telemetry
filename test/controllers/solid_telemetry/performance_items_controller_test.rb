require "test_helper"

module SolidTelemetry
  class PerformanceItemsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get performance_items_url
      assert_response :success
    end

    test "should get show" do
      get performance_item_url(solid_telemetry_performance_items(:performance_item_1))
      assert_response :success
    end
  end
end
