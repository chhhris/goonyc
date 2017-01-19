class Trip < ApplicationRecord

  class << self

    # add to env
    API_KEY = 've518156965014636303894819187830'

    DESTINATION_NAME_MAPPING = {
      STT: 'Saint Thomas',
      CUN: 'Tulum',
      POS: 'Port of Spain'
    }

    PARAMS = {
      country: 'US',
      currency: 'USD',
      locale: 'en-US',
      locationSchema: 'iata',
      apikey: API_KEY,
      originplace: 'JFK-sky',
      adults: 1,
      children: 0,
      infants: 0,
      cabinclass: 'Economy'
    }

    def generate_flights
      first_date = Date.parse('Friday') + 14.days

      # TODO clean up date formatting
      departure_dates = [ first_date, first_date + 14.days, first_date + 28.days ]
      return_dates = departure_dates.map { |d| d + 3.days }

      departure_dates = departure_dates.map { |d| d.strftime('%Y-%m-%d') }
      return_dates = return_dates.map { |d| d.strftime('%Y-%m-%d') }

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

      post_url = "http://business.skyscanner.net/apiservices/pricing/v1.0/?apikey=#{API_KEY}"

      RestClient.post(post_url, params, { Accept: 'application/json' }) do |response, request, result, &block|
        if response.code == 201
          polling_url = response.headers[:location]
          poll_response_and_save(polling_url, code, depart_at, return_at)
        end
      end
    end

    def poll_response_and_save(polling_url, code, depart_at, return_at)
      RestClient.get("#{polling_url}?apiKey=#{API_KEY}", { accept: :json }) do |response, request, result, &block|
        return unless response.code == 200

        cheapest_flight = JSON.parse(response)['Itineraries'].first

        # price
        flight_cost = cheapest_flight['PricingOptions'].first['Price']

        # link to book it
        booking_link = cheapest_flight['PricingOptions'].first['DeeplinkUrl']

        trip = Trip.new(name: DESTINATION_NAME_MAPPING[code.to_sym], code: code, depart_at: depart_at, return_at: return_at,
            price: flight_cost, url: booking_link, featured: false)

        trip.save
      end
    end

  end

end
