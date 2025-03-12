module Restaurants
  class StubCreatorService
    def self.create(user:, google_restaurant:)
      # First check if user already has this restaurant
      existing_restaurant = user.restaurants.find_by(google_restaurant: google_restaurant)
      return [ existing_restaurant, :existing ] if existing_restaurant

      # If not, create new restaurant
      new_restaurant = user.restaurants.create!(
        google_restaurant: google_restaurant,
        name: google_restaurant.name,
        rating: 0,
        price_level: 0,
        cuisine_type: CuisineType.find_by!(name: "other")
      )
      [ new_restaurant, :new ]
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create restaurant: #{e.message}"
      raise
    end
  end
end
