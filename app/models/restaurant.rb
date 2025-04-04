class Restaurant < ApplicationRecord
    include PgSearch::Model

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
    delegate :latitude, :longitude, :location, to: :google_restaurant, allow_nil: true

    validates :name, presence: true, unless: -> { google_restaurant.present? }
    validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
    validates :price_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
    validates :business_status, inclusion: { in: [ "OPERATIONAL", "CLOSED_TEMPORARILY", "CLOSED_PERMANENTLY" ] }, allow_nil: true
    validates :organization, presence: true

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

    def self.search_by_name_and_address(query, organization)
      search_by_all_fields(query).where(organization_id: organization.id)
    end

    scope :near, ->(lat, lon, distance_in_meters = 50000) {
      joins(:google_restaurant)
        .where(
          "ST_DWithin(google_restaurants.location::geography, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :distance)",
          lat: lat.to_f,
          lon: lon.to_f,
          distance: distance_in_meters.to_f
        )
    }

    scope :order_by_distance_from, ->(lat, lon) {
      lon_val = lon.to_f
      lat_val = lat.to_f
      joins(:google_restaurant)
        .select("restaurants.*, ST_Distance(google_restaurants.location::geography, ST_SetSRID(ST_MakePoint(#{lon_val}, #{lat_val}), 4326)::geography) as distance")
        .order('distance')
    }

    GOOGLE_FALLBACK_ATTRIBUTES = [
      :name, :address, :street, :street_number, :city, :state, :country,
      :postal_code, :phone_number, :url, :business_status, :latitude, :longitude
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
      return nil unless google_restaurant&.location

      GoogleRestaurant
        .select("ST_Distance(location, ST_SetSRID(ST_MakePoint(#{lon}, #{lat}), 4326)::geography) as distance")
        .find(google_restaurant_id)
        .distance
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
      end
    rescue ActiveRecord::RecordNotUnique
      # If we hit a race condition, try to find the existing copy
      RestaurantCopy.find_by!(organization_id: target_organization.id, restaurant_id: self.id).copied_restaurant
    end
end
