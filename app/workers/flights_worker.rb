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
      if response.code == 201
        polling_url = response.headers[:location]

        perform(polling_url, params, polling: true)
      end
    end
  end

  def get(polling_url, params)
    RestClient.get("#{polling_url}?apiKey=#{Trip::FLIGHT_API_KEY}", { accept: :json }) do |response, request, result, &block|
      return unless response.code == 200

      cheapest_flight = JSON.parse(response)['Itineraries'].first

      if cheapest_flight.present?
        flight_price = cheapest_flight['PricingOptions'].first['Price']
        booking_link = cheapest_flight['PricingOptions'].first['DeeplinkUrl']
        code = params['destinationplace']
        depart_at = params['outbounddate']
        return_at = params['inbounddate']
        inbounddate = params['return_at']
        puts "params flight worker #{params}"
        trip = Trip.where(code: code, depart_at: depart_at.to_date, return_at: return_at.to_date).first_or_initialize
        trip.name = Trip::DESTINATION_NAME_MAPPING[code.to_sym][:name]
        trip.price = flight_price
        trip.url = booking_link
        trip.save
      end
    end
  end
end
