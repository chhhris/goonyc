class TemperaturesWorker
  include Sidekiq::Worker

  def perform(url, trip_id)
    avg_high = RestClient.get(url) do |resp|
      if resp.body
        parsed_json = JSON.parse(resp.body)
        if parsed_json['trip'].present?
          parsed_json['trip']['temp_high']['avg']['F']
        end
      end
    end

    if avg_high.present?
      trip = Trip.find(trip_id)
      trip.update_column(:temperature, avg_high.to_i)
    end
  end
end
