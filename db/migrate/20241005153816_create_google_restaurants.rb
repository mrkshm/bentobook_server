class CreateGoogleRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :google_restaurants do |t|
      t.string :name
      t.string :google_place_id
      t.text :address
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.string :street
      t.string :street_number
      t.string :postal_code
      t.string :city
      t.string :state
      t.string :country
      t.string :phone_number
      t.string :url
      t.string :business_status
      t.float :google_rating
      t.integer :google_ratings_total
      t.integer :price_level
      t.json :opening_hours
      t.datetime :google_updated_at

      t.timestamps
    end

    add_index :google_restaurants, :address
    add_index :google_restaurants, :city
    add_index :google_restaurants, :google_place_id, unique: true
    add_index :google_restaurants, :name
  end
end