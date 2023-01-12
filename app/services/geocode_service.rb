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