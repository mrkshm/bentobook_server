class RestaurantSerializer < BaseSerializer
  include Rails.application.routes.url_helpers

  # Basic attributes
  attributes :id,
             :notes,
             :favorite,
             :created_at,
             :updated_at,
             :visit_count

  # Core restaurant details
  attribute :name do |restaurant|
    restaurant.combined_name
  end

  attribute :cuisine_type do |restaurant|
    restaurant.cuisine_type&.name
  end

  attribute :price_level do |restaurant|
    restaurant.price_level
  end

  attribute :rating do |restaurant|
    restaurant.rating
  end

  attribute :business_status do |restaurant|
    restaurant.combined_business_status
  end

  # Location details
  attribute :location do |restaurant|
    {
      address: restaurant.combined_address,
      street: restaurant.combined_street,
      street_number: restaurant.combined_street_number,
      city: restaurant.combined_city,
      state: restaurant.combined_state,
      country: restaurant.combined_country,
      postal_code: restaurant.combined_postal_code,
      latitude: restaurant.combined_latitude&.to_f,
      longitude: restaurant.combined_longitude&.to_f
    }
  end

  # Visits
  attribute :visits do |restaurant|
    restaurant.visits.map do |visit|
      {
        id: visit.id,
        date: visit.date,
        rating: visit.rating,
        notes: visit.notes,
        created_at: visit.created_at,
        updated_at: visit.updated_at
      }
    end
  end

  # Contact information
  attribute :contact_info do |restaurant|
    {
      phone_number: restaurant.combined_phone_number,
      url: restaurant.combined_url
    }
  end

  # Images
  attribute :images do |restaurant|
    restaurant.images.map do |image|
      next unless image.file.attached?

      {
        id: image.id,
        created_at: image.created_at,
        urls: {
          thumbnail: url_for(image.file.variant(resize_to_fill: [ 100, 100 ])),
          small: url_for(image.file.variant(resize_to_limit: [ 300, 200 ])),
          medium: url_for(image.file.variant(resize_to_limit: [ 600, 400 ])),
          large: url_for(image.file.variant(resize_to_limit: [ 1200, 800 ])),
          original: url_for(image.file)
        }
      }
    end.compact
  end

  # Google Places information
  attribute :google_place_id do |restaurant|
    restaurant.google_restaurant&.google_place_id
  end

  # Distance calculation (when user location is provided)
  attribute :distance do |restaurant|
    if @params[:user_location]
      restaurant.distance_to(@params[:user_location][0], @params[:user_location][1])
    end
  end

  # Related data
  attribute :tags do |restaurant|
    restaurant.tag_list
  end
end
