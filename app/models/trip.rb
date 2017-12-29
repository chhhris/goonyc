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

  class << self
    include TripDestinations

    def admin_trips_display
      display_trips = []
      trips = Trip.all.order({name: :asc}, {price: :asc})

      trips.each do |trip|
        unless display_trips.last && display_trips.last.name == trip.name
          display_trips << trip
        end
      end

      display_trips
    end

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
      puts "params trip.rb #{params}"
      post_url = "http://business.skyscanner.net/apiservices/pricing/v1.0/?apikey=#{FLIGHT_API_KEY}"

      FlightsWorker.perform_async(post_url, params)
    end

    def update_temperatures
      Trip.all.each do |trip|
        p_depart = trip.depart_at.strftime('%m%d')
        p_return = trip.return_at.strftime('%m%d')
        destination = DESTINATION_NAME_MAPPING[trip.code.to_sym][:weather_lookup]
        url = "http://api.wunderground.com/api/#{WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json"
        TemperaturesWorker.perform_async(url, trip.id)
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
