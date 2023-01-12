# Weather forecaster


## Scope

1. Use Ruby On Rails. 

2. Accept an address as input. 

3. Retrieve forecast data for the given address. This should include, at minimum, the current temperature. Bonus points: retrieve high/low and/or extended forecast.

4. Display the requested forecast details to the user.

5. Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator in result is pulled from cache.


## Set up Rails

This app is developed on a MacBook Pro M1 with rails version 7.0.4 and ruby 3.0.4p208.



### Install Ruby

Install `ruby` using rvm

```sh
\curl -sSL https://get.rvm.io | bash
```

```sh
rvm install 3.0.4
```


### Install Rails

Install Ruby on Rails:

```sh
% gem install rails
```


## Set up the app


### Create a new app using rails

Create a new Ruby on Rails app and start server:

```sh
% rails new address_forecaster -c bootstrap
% cd address_forecaster
% rails s
% curl http://127.0.0.1:3000
```


### Set the root path route

Edit `config/routes.rb`:

```ruby
# Defines the root path route ("/")
root "forecasts#show"
```



## Get forecast data for the given address

There are many ways we could get forecast data. 

* We choose to convert the address to a latitude and longitude, by using the geocoder gem and using Google geocoder api

* Send the latitude and longitude to the OpenWeatherMap API available [here](https://openweathermap.com)

* We choose to implement each API as an application service in the directory `app/services`

Run:

```sh
% mkdir app/services
% mkdir test/services
```


### Set Geocoder API credentials

Edit Rails credentials:

```sh
EDITOR=vim rails credentials:edit
```

Add your geocoder api key

```ruby
geocoder_api_key: ''
```


### Add Geocoder gem

Edit `Gemfile` to add:

```ruby
# Look up a map address and convert it to latitude, longitude, etc.
gem "geocoder"
```

Run:

```sh
bundle
```


### Configure Geocoder

Create `config/initializers/geocoder.rb`:

```ruby
Geocoder.configure(api_key: Rails.application.credentials.geocoder_api_key)
```


### Create GeocodeService

Create a geocode service that converts from an address string into a latitude, longitude, country code, and postal code.

Create `test/services/geocode_service_test`:

```ruby
require 'test_helper'

class GeocodeServiceTest < ActiveSupport::TestCase

  test "call with address" do
    address = "15303 NE 13th PL, Bellevue"
    geocode = GeocodeService.call!(address)
    assert_in_delta 47.63, geocode.latitude, 0.1
    assert_in_delta -122.13, geocode.longitude, 0.1
    assert_equal "us", geocode.country_code
    assert_equal "98007", geocode.postal_code
  end

end
```

Create `app/services/geocode_service`:

```ruby
class GeocodeService 

  def self.call!(address)
    response = Geocoder.search(address)
    
    begin
      geocode = OpenStruct.new
      data = response.last.data
      geocode.latitude = data["lat"].to_f
      geocode.longitude = data["lon"].to_f
      geocode.country_code = data["address"]["country_code"]
      geocode.postal_code = data["address"]["postcode"]
      geocode
    rescue Exception => e
      raise StandardError.new("Geocoder error")
    end
  end
end
```


## Join OpenWeather API

Sign up at <https://openweathermap.org>

* Create an API key. It will send email with API key and API key will be activated after 2 hours of sign up


### Set OpenWeather API credentials

Edit Rails credentials:

```sh
EDITOR=vim  bin/rails credentials:edit
```

Add your OpenWeather API key in credentials

```ruby
weather_api_key: ''
```


### Add httparty gem

we are using httparty for API call

Edit `Gemfile` and add:

```ruby
gem "httparty"
```

Run:

```sh
bundle
```


### Create WeatherService

Create `test/services/weather_service_test.rb`:

```ruby
require 'test_helper'

class WeatherServiceTest < ActiveSupport::TestCase

  test "call with latitude and longitude" do
    latitude = 47.13
    longitude = -122.13 
    weather = WeatherService.call(latitude, longitude)
    assert_includes 20..120, weather.temperature
    assert_includes 20..120, weather.temperature_min
    assert_includes 20..120, weather.temperature_max
    assert_includes 0..100, weather.humidity
    assert_includes 900..1100, weather.pressure
    refute_empty weather.description
  end

end
```

Create `app/services/weather_service.rb`:

```ruby
class WeatherService
    
  def self.call!(latitude, longitude)
    response = api_call(latitude, longitude)

    parse_response!(response)
  end

  private 

  def self.api_call(lat, lon)
    HTTParty.get("https://api.openweathermap.org/data/2.5/weather?appid=#{Rails.application.credentials.weather_api_key}&lat=#{lat}&lon=#{lon}&units=imperial")
  end

  def self.parse_response!(response)
    body = JSON.parse(response.body)
    weather = OpenStruct.new
    if body && body["main"] && body["main"]["temp"]
      weather.temperature = body["main"]["temp"]
    else
      StandardError.new "OpenWeather failed, temperature missing"
    end
    weather.temperature_min = body["main"]["temp_min"]
    weather.temperature_max = body["main"]["temp_max"]
    weather.humidity = body["main"]["humidity"]
    weather.pressure = body["main"]["pressure"]
    weather.description = body["weather"][0]["description"]
    weather
  end
    
end

```



```

### Enable the cache

Enable the Rails development cache.


```sh
bin/rails dev:cache
```


## Testing

The app now works successfully:

```sh
% bin/rails test
% bin/rails test:system
% bin/rails s
```

Browse to <http://127.0.0.1:3000>




### Future ideas

Improve UX of the APP.

Add more test cases specially around API call.

Provide an option to use preferred temp units.

Add circuit breakers for the Weather API call and dynamic cache time based on circuit breaker.



