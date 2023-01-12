require "application_system_test_case"

class ForecastsTest < ApplicationSystemTestCase
  test "visiting the root url" do
    visit root_url
  
    assert_selector "Bellevue downtown", text: "Forecasts"
  end
end
