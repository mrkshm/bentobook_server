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
class Restaurant < ApplicationRecord
    include PgSearch::Model

    enum business_status: {
        operational: "OPERATIONAL",
        closed_permanently: "CLOSED_PERMANENTLY",
        closed_temporarily: "CLOSED_TEMPORARILY"
    }, _default: :operational

    belongs_to :organization
    belongs_to :google_restaurant, optional: true
    accepts_nested_attributes_for :google_restaurant
    belongs_to :cuisine_type, optional: true
    has_many :visits, dependent: :restrict_with_error
    has_many :images, as: :imageable, dependent: :destroy
    has_many :list_restaurants, class_name: "ListRestaurant", dependent: :destroy
    has_many :lists, through: :list_restaurants
    has_many :copies, class_name: "Restaurant", foreign_key: :original_restaurant_id
    belongs_to :original_restaurant, class_name: "Restaurant", optional: true
    has_many :restaurant_copies_as_copy, class_name: "RestaurantCopy", foreign_key: :copied_restaurant_id, dependent: :destroy

    acts_as_taggable_on :tags

    validates :name, presence: true, unless: -> { google_restaurant.present? }
    validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
    validates :price_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
    validates :business_status, inclusion: { in: business_statuses.keys }, allow_nil: true
    validates :organization, presence: true
    validates :latitude, numericality: true, allow_nil: true
    validates :longitude, numericality: true, allow_nil: true

    scope :favorites, -> { where(favorite: true) }

    pg_search_scope :search_by_all_fields,
                    against: {
                      name: "A",
                      address: "B",
                      notes: "D"
                    },
                    associated_against: {
                      google_restaurant: {
                        name: "A",
                        address: "B",
                        postal_code: "C",
                        city: "C",
                        country: "C"
                      }
                    },
                    using: {
                      tsearch: {
                        prefix: true,
                        dictionary: "english",
                        tsvector_column: "tsv"
                      }
                    }

    def self.search(query)
      search_by_all_fields(query)
    end

    # Update scope to use restaurant's own location data
    scope :near, ->(lat, lon, distance_in_meters = 50000) {
      where(
        "ST_DWithin(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :distance)",
        lat: lat.to_f,
        lon: lon.to_f,
        distance: distance_in_meters.to_f
      )
    }

    # Update scope to order by distance using restaurant's own location data
    scope :order_by_distance_from, ->(lat, lon) {
      lon_val = lon.to_f
      lat_val = lat.to_f
      select("restaurants.*, ST_Distance(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography, ST_SetSRID(ST_MakePoint(#{lon_val}, #{lat_val}), 4326)::geography) as distance")
        .order("distance")
    }

    GOOGLE_FALLBACK_ATTRIBUTES = [
      :name, :address, :street, :street_number, :city, :state, :country,
      :postal_code, :phone_number, :url, :business_status
    ]

    GOOGLE_FALLBACK_ATTRIBUTES.each do |attr|
      define_method("combined_#{attr}") do
        self[attr].presence || google_restaurant&.public_send(attr)
      end
    end

    def self.with_google
      joins("LEFT JOIN google_restaurants ON restaurants.google_restaurant_id = google_restaurants.id")
        .select("restaurants.*, " +
                GOOGLE_FALLBACK_ATTRIBUTES.map { |attr|
                  "COALESCE(restaurants.#{attr}, google_restaurants.#{attr}) AS combined_#{attr}"
                }.join(", ") +
                ", restaurants.price_level AS restaurant_price_level, restaurants.rating AS restaurant_rating")
    end

    def visit_count
      visits.count
    end

    def parsed_opening_hours
      JSON.parse(opening_hours) if opening_hours.present?
    rescue JSON::ParserError
      nil
    end

    def distance_to(lat, lon)
      return nil unless latitude && longitude

      # Use the Restaurant class to query the distance
      result = Restaurant.connection.execute(
        "SELECT ST_Distance(ST_SetSRID(ST_MakePoint(#{longitude}, #{latitude}), 4326)::geography, ST_SetSRID(ST_MakePoint(#{lon}, #{lat}), 4326)::geography) as distance"
      ).first

      result["distance"].to_f
    end

    def price_level_display
      "$" * price_level if price_level
    end

    scope :order_by_visits, ->(direction = :desc) {
      left_joins(:visits)
        .group("restaurants.id")
        .order(Arel.sql("COUNT(visits.id) #{direction.to_s.upcase}"))
    }

    # Copy a restaurant to another organization
    def copy_for_organization(target_organization)
      return self if target_organization == self.organization

      transaction do
        # Check if a copy already exists
        existing_copy = RestaurantCopy.find_by(organization_id: target_organization.id, restaurant_id: self.id)
        return existing_copy.copied_restaurant if existing_copy

        copy = self.dup
        copy.organization = target_organization
        copy.original_restaurant = self
        copy.save!

        RestaurantCopy.create!(
          organization_id: target_organization.id,
          restaurant_id: self.id,
          copied_restaurant: copy
        )

        copy
      rescue ActiveRecord::RecordNotUnique
        # If we hit a race condition, try to find the existing copy
        RestaurantCopy.find_by!(organization_id: target_organization.id, restaurant_id: self.id).copied_restaurant
      end
    end
end
