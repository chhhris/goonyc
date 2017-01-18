json.extract! trip, :id, :code, :name, :price, :depart_at, :return_at, :url, :featured, :created_at, :updated_at
json.url trip_url(trip, format: :json)