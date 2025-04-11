class CopyLocationDataFromGoogleRestaurantsToRestaurants < ActiveRecord::Migration[8.0]
  def up
    # Find all restaurants with a google_restaurant_id but no latitude/longitude
    execute <<-SQL
      UPDATE restaurants
      SET#{' '}
        latitude = google_restaurants.latitude,
        longitude = google_restaurants.longitude
      FROM google_restaurants
      WHERE#{' '}
        restaurants.google_restaurant_id = google_restaurants.id
        AND (restaurants.latitude IS NULL OR restaurants.longitude IS NULL)
        AND google_restaurants.latitude IS NOT NULL
        AND google_restaurants.longitude IS NOT NULL
    SQL

    # Log the results
    restaurant_count = execute("SELECT COUNT(*) FROM restaurants WHERE latitude IS NOT NULL AND longitude IS NOT NULL").first["count"]
    puts "Updated location data for #{restaurant_count} restaurants"
  end

  def down
    # This migration is not reversible as it's a data migration
    # We could technically set latitude and longitude back to NULL, but that would be destructive
    raise ActiveRecord::IrreversibleMigration
  end
end
