require 'test_helper'

class GeocodeServiceTest < ActiveSupport::TestCase

  test "call with known address" do
    address = "15303 NE 13th PL, Bellevue, WA"
    geocode = GeocodeService.call!(address)
    assert_in_delta 47.63, geocode.latitude, 0.1
    assert_in_delta -122.13, geocode.longitude, 0.1
    assert_equal "us", geocode.country_code
    assert_equal "98007", geocode.postal_code
  end

end
