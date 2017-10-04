class Trip < ApplicationRecord
  include TripDestinations

  FLIGHT_API_KEY = ENV['SKY_SCANNER_API']
  WEATHER_API_KEY = ENV['WEATHER_API']

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
    destination = DESTINATION_NAME_MAPPING[self.code.to_sym][:weather_lookup]
    url = "http://api.wunderground.com/api/#{WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json"

    avg_high = RestClient.get(url) do |resp|
      parsed_json = JSON.parse(resp.body)
      if parsed_json['trip'].present?
        parsed_json['trip']['temp_high']['avg']['F']
      end
    end

    if avg_high.present?
      self.update_column(:temperature, avg_high.to_i)
    end

  end

  class << self
    include TripDestinations

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
      params = PARAMS.merge( destinationplace: code, outbounddate: depart_at, inbounddate: return_at)

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

        cheapest_flight = JSON.parse(response)['Itineraries'].first
        if cheapest_flight.present?
          flight_price = cheapest_flight['PricingOptions'].first['Price']
          booking_link = cheapest_flight['PricingOptions'].first['DeeplinkUrl']

          trip = Trip.where(code: code, depart_at: depart_at.to_date, return_at: return_at.to_date).first_or_initialize
          trip.name = DESTINATION_NAME_MAPPING[code.to_sym][:name]
          trip.price = flight_price
          trip.url = booking_link
          trip.save
        end
      end
    end

    def remove_old_trips
      trips = Trip.where('depart_at < ?', 1.week.from_now)
      if trips.present?
        trips.destroy_all
      end
    end

  end
end
