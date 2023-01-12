require 'test_helper'

class WeatherServiceTest < ActiveSupport::TestCase

  test "call with known parameters" do
    latitude = 47.63
    longitude = -122.13 
    weather = WeatherService.call!(latitude, longitude)
    assert_includes 20..100, weather.temperature
    assert_includes 20..100, weather.temperature_min
    assert_includes 20..100, weather.temperature_max
    assert_includes 0..100, weather.humidity
    assert_includes 900..1100, weather.pressure
    refute_empty weather.description
  end

end
