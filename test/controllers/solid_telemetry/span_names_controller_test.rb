require "test_helper"

module SolidTelemetry
  class SpanNamesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get index" do
      get span_names_url
      assert_response :success
    end

    test "should get show" do
      get span_name_url(solid_telemetry_span_names(:posts_index_span_name))
      assert_response :success
    end
  end
end
