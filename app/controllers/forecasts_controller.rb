class ForecastsController < ApplicationController
  
  def show
    @address_default = "15303 NE 13th PL, Bellevue, Washington"
    session[:address] = params[:address]
    if params[:address]
      begin
        @address = params[:address]
        @geocode = GeocodeService.call!(@address)
        @weather_cache_key = "#{@geocode.country_code}/#{@geocode.postal_code}"
        @weather_cache_hit = Rails.cache.exist?(@weather_cache_key)
        @weather = Rails.cache.fetch(@weather_cache_key, expires_in: 30.minutes) do
          @weather = WeatherService.call!(@geocode.latitude, @geocode.longitude)          
        end
      rescue => e
        @error_message = e.message
      end
    end
  end
end
