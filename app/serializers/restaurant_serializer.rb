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
      latitude: restaurant.latitude&.to_f,
      longitude: restaurant.longitude&.to_f
    }
  end

  attribute :distance do |restaurant|
    if user_location? && restaurant.latitude && restaurant.longitude
      Geocoder::Calculations.distance_between(
        user_location,
        [ restaurant.latitude, restaurant.longitude ],
        units: :km
      ).round(1)
    end
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

  # Related data
  attribute :tags do |restaurant|
    restaurant.tag_list
  end

  private

  def user_location?
    @options[:params]&.dig(:user_location).present?
  end

  def user_location
    @options[:params][:user_location]
  end
end
