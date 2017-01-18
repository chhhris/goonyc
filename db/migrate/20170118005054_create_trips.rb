class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.string :code
      t.string :name
      t.string :price
      t.datetime :depart_at
      t.datetime :return_at
      t.string :url
      t.boolean :featured

      t.timestamps
    end
  end
end
