# == Schema Information
#
# Table name: restaurants
#
#  id                     :bigint           not null, primary key
#  address                :text
#  business_status        :string
#  city                   :string
#  country                :string
#  favorite               :boolean          default(FALSE)
#  latitude               :decimal(10, 8)
#  longitude              :decimal(11, 8)
#  name                   :string
#  notes                  :text
#  opening_hours          :json
#  phone_number           :string
#  postal_code            :string
#  price_level            :integer
#  rating                 :integer
#  state                  :string
#  street                 :string
#  street_number          :string
#  tsv                    :tsvector
#  url                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  cuisine_type_id        :bigint
#  google_restaurant_id   :bigint
#  organization_id        :bigint
#  original_restaurant_id :bigint
#
# Indexes
#
#  index_restaurants_on_address                 (address)
#  index_restaurants_on_city                    (city)
#  index_restaurants_on_cuisine_type_id         (cuisine_type_id)
#  index_restaurants_on_favorite                (favorite)
#  index_restaurants_on_google_restaurant_id    (google_restaurant_id)
#  index_restaurants_on_name                    (name)
#  index_restaurants_on_notes                   (notes)
#  index_restaurants_on_organization_id         (organization_id)
#  index_restaurants_on_original_restaurant_id  (original_restaurant_id)
#  restaurants_tsv_idx                          (tsv) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (cuisine_type_id => cuisine_types.id)
#  fk_rails_...  (google_restaurant_id => google_restaurants.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (original_restaurant_id => restaurants.id)
#
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
