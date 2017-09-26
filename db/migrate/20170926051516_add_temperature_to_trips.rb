class AddTemperatureToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :temperature, :integer
  end
end
