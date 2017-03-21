class Trip < ApplicationRecord

  FLIGHT_API_KEY = ENV['SKY_SCANNER_API']
  WEATHER_API_KEY = ENV['WEATHER_API']

  DESTINATION_NAME_MAPPING = {
    STT: { name: 'Saint Thomas', weather_lookup: 'STT' }
    CUN: { name: 'Tulum', weather_lookup: 'QR/Cancun_International' },
    POS: { name: 'Port of Spain', weather_lookup: 'TD/Piarco_sInternational' }
  }

  PARAMS = {
    country: 'US',
    currency: 'USD',
    locale: 'en-US',
    locationSchema: 'iata',
    apikey: FLIGHT_API_KEY,
    originplace: 'JFK-sky',
    adults: 1,
    children: 0,
    infants: 0,
    cabinclass: 'Economy'
  }

  after_save :update_temperature

  def update_temperature
    p_depart = self.depart_at.strftime('%m%d')
    p_return = self.return_at.strftime('%m%d')
    destination = DESTINATION_NAME_MAPPING[self.code.to_sym]['weather_lookup']

    url = "http://api.wunderground.com/api/#{WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json"

    avg_high = open(url) do |resp| 
      parsed_json = JSON.parse(resp.read) 
      parsed_json['trip']['temp_high']['avg']['F']
    end

    self.temperature = avg_high
    self.save
  end

  class << self

    def generate_flights
      first_date = Date.parse('Thursday') + 14.days

      # TODO clean up date formatting
      departure_dates = [ first_date, first_date + 14.days, first_date + 28.days ].map { |d| d.strftime('%Y-%m-%d') }
      return_dates = departure_dates.map { |departure| Date.parse(departure) + 3.days }.map { |d| d.strftime('%Y-%m-%d') }

      departure_dates.each_with_index do |depart_at, index|
        return_at = return_dates[index]

        DESTINATION_NAME_MAPPING.each do |code, name|
          search_api(code.to_s, depart_at, return_at)
        end
      end
    end

    def search_api(code, depart_at, return_at)
      params = PARAMS.merge( destinationplace: code, outbounddate: depart_at,
          inbounddate: return_at)

      post_url = "http://business.skyscanner.net/apiservices/pricing/v1.0/?apikey=#{FLIGHT_API_KEY}"
      
      RestClient.post(post_url, params, { Accept: 'application/json' }) do |response, request, result, &block|
        if response.code == 201
          polling_url = response.headers[:location]
          poll_response_and_save(polling_url, code, depart_at, return_at)
        end
      end
    end

    def poll_response_and_save(polling_url, code, depart_at, return_at)
      RestClient.get("#{polling_url}?apiKey=#{FLIGHT_API_KEY}", { accept: :json }) do |response, request, result, &block|
        return unless response.code == 200

        destination = DESTINATION_NAME_MAPPING[code.to_sym]['name']
        cheapest_flight = JSON.parse(response)['Itineraries'].first
        flight_price = cheapest_flight['PricingOptions'].first['Price']
        booking_link = cheapest_flight['PricingOptions'].first['DeeplinkUrl']

        trip = Trip.where(code: code, name: destination, depart_at: depart_at, return_at: return_at).first_or_initialize
        trip.price = flight_price
        trip.url = booking_link
        trip.save
      end
    end

  end
end

if 1 < 0 

  p_depart = self.depart_at.strftime('%m%d')
  p_return = self.return_at.strftime('%m%d')
  destination = DESTINATION_NAME_MAPPING[self.code.to_sym]['weather_lookup']

  url = "http://api.wunderground.com/api/#{WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json"

  avg_high = open(url) do |resp| 
    parsed_json = JSON.parse(resp.read) 
    parsed_json['trip']['temp_high']['avg']['F']
  end

  self.temperature = avg_high
  self.save
  
  

  depart_at = '0504'
  return_at = '0507'
  url = "http://api.wunderground.com/api/#{api_key}/planner_#{depart_at}#{return_at}/q/TT/Piarco_International.json"
  open(url) { |resp| @parsed_json = JSON.parse(resp.read) }
  @parsed_json['trip']['temp_high']['avg']['F']

# weather api
  api_key = '37f2fcd1fbfbe9b0'

  url = "http://api.wunderground.com/api/#{api_key}/forecast/q/TT/Piarco_International.json"
  open(url) { |resp| @parsed_json = JSON.parse(resp.read) }

  url = "http://api.wunderground.com/api/#{api_key}/forecast/q/STT.json"
  
  forecast_high = @parsed_json['forecast']['simpleforecast']['forecastday'].first['high']['fahrenheit']

  url = "http://api.wunderground.com/api/#{api_key}/geolookup/conditions/q/IA/Cedar_Rapids.json"

  require 'open-uri'
  require 'json'
  
  open(url) do |f|
    json_string = f.read
    @parsed_json = JSON.parse(json_string)
    location = @parsed_json['location']['city']
    temp_f = @parsed_json['current_observation']['temp_f']
    print "Current temperature in #{location} is: #{temp_f}\n"
  end
end