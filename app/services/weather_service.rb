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
