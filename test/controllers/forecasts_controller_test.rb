require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get show with root path" do
    get root_url
    assert_response :success
    assert_equal "/", path
  end
end
