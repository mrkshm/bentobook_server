class CreateRestaurants < ActiveRecord::Migration[8.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.text :address
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.text :notes
      t.references :user, foreign_key: true
      t.references :google_restaurant, foreign_key: true
      t.references :cuisine_type, foreign_key: true
      t.string :street
      t.string :street_number
      t.string :postal_code
      t.string :city
      t.string :state
      t.string :country
      t.string :phone_number
      t.string :url
      t.string :business_status
      t.integer :rating
      t.integer :price_level
      t.json :opening_hours
      t.boolean :favorite, default: false

      t.timestamps
    end

    add_index :restaurants, :address
    add_index :restaurants, :city
    add_index :restaurants, :favorite
    add_index :restaurants, :name
    add_index :restaurants, :notes
    add_index :restaurants, [:user_id, :google_restaurant_id], unique: true
  end
end
