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
    stops: 0,
    sortOrder: 'asc',
    cabinclass: 'Economy'
  }

  class << self
    include TripDestinations

    def admin_trips_display!
      display_trips = []
      trips = Trip.all.order({name: :asc}, {price: :asc})

      trips.each do |trip|
        if display_trips.last && display_trips.last.name == trip.name
          trip.destroy
        else
          display_trips << trip
        end
      end

      display_trips
    end

    def generate_flights
      first_date = Date.parse('Thursday') + 21.days
      departure_dates = [ first_date + 14.days ].map { |d| d.strftime('%Y-%m-%d') }
      return_dates = departure_dates.map { |departure| Date.parse(departure) + 3.days }.map { |d| d.strftime('%Y-%m-%d') }

      departure_dates.each_with_index do |depart_at, index|
        return_at = return_dates[index]
        Trip::DESTINATION_NAME_MAPPING.each do |code, name|
          search_api(code.to_s, depart_at, return_at)
        end
      end
    end

    def search_api(code, depart_at, return_at)
      params = Trip::PARAMS.merge( destinationplace: code, outbounddate: depart_at, inbounddate: return_at)
      url = "http://business.skyscanner.net/apiservices/pricing/v1.0/?apikey=#{Trip::FLIGHT_API_KEY}"

      FlightsWorker.perform_async(url, params)
    end

    def update_temperatures
      Trip.where(temperature: nil).each do |trip|
        p_depart, p_return = trip.depart_at.strftime('%m%d'), trip.return_at.strftime('%m%d')
        destination = Trip::DESTINATION_NAME_MAPPING[trip.code.to_sym][:weather_lookup]
        url = "http://api.wunderground.com/api/#{Trip::WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json"
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
