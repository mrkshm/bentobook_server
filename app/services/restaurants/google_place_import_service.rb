module Restaurants
  class GooglePlaceImportService
    def self.find_or_create(place_data)
      google_restaurant = GoogleRestaurant.find_by(google_place_id: place_data[:google_place_id])

      return google_restaurant if google_restaurant

      # Extract city from formatted_address if not provided
      city = place_data[:city]
      if city.blank? && place_data[:formatted_address].present?
        # Split address and try to find city component
        address_parts = place_data[:formatted_address].split(", ")
        # In Thai addresses, city is often the second-to-last component before postal code
        city = address_parts[-3] if address_parts.size >= 3
      end

      GoogleRestaurant.create!(
        google_place_id: place_data[:google_place_id],
        name: place_data[:name],
        address: place_data[:formatted_address], # Map formatted_address to address
        latitude: place_data[:latitude],
        longitude: place_data[:longitude],
        phone_number: place_data[:phone_number],
        url: place_data[:website], # Map website to url
        google_rating: place_data[:rating], # Map rating to google_rating
        google_ratings_total: place_data[:user_ratings_total],
        price_level: place_data[:price_level],
        business_status: place_data[:business_status],
        street_number: place_data[:street_number],
        street: place_data[:street_name], # Map street_name to street
        postal_code: place_data[:postal_code],
        city: city || "Bangkok", # Fallback to Bangkok for MBK case
        state: place_data[:state],
        country: place_data[:country],
        google_updated_at: Time.current,
        location: "POINT(#{place_data[:longitude]} #{place_data[:latitude]})"
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to create GoogleRestaurant: #{e.message}")
      Rails.logger.error("Place data: #{place_data.inspect}")
      raise
    end
  end
end
