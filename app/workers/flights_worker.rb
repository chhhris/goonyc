class FlightsWorker
  include Sidekiq::Worker

  def perform(url, params, polling: false)

    if polling == false
      post(url, params)
    else
      get(url, params)
    end
  end

  private

  def post(url, params)
    RestClient.post(url, params, { Accept: 'application/json' }) do |response, request, result, &block|
      puts "POST response.code #{response.code}"
      if response.code == 201
        polling_url = response.headers[:location]

        perform(polling_url, params, polling: true)
      end
    end
  end

  def get(polling_url, params)
    RestClient.get("#{polling_url}?apiKey=#{Trip::FLIGHT_API_KEY}", { accept: :json }) do |response, request, result, &block|
      puts "#### GET response.code #{response.code}"
      return unless response.code == 200
      cheapest_flight = JSON.parse(response)['Itineraries'].first

      if cheapest_flight.present?
        puts "#### params #{params}"
        pricing_options = cheapest_flight['PricingOptions'].first
        params = params.with_indifferent_access

        trip = Trip.where(
          code: params['destinationplace'],
          depart_at: params['outbounddate'].to_date,
          return_at: params['inbounddate'].to_date
        ).first_or_initialize
        trip.name = Trip::DESTINATION_NAME_MAPPING[code.to_sym][:name]
        trip.price = pricing_options['Price']
        trip.url = pricing_options['DeeplinkUrl']

        if trip.save
          p_depart, p_return = trip.depart_at.strftime('%m%d'), trip.return_at.strftime('%m%d')
          destination = Trip::DESTINATION_NAME_MAPPING[trip.code.to_sym][:weather_lookup]
          url = "http://api.wunderground.com/api/#{Trip::WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json"
          TemperaturesWorker.perform_async(url, trip.id)
        end
      end
    end
  end
end
