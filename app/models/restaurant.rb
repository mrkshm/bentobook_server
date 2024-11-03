class Restaurant < ApplicationRecord
    include PgSearch::Model

    belongs_to :user
    belongs_to :google_restaurant
    accepts_nested_attributes_for :google_restaurant
    has_many :visits, dependent: :restrict_with_error
    has_many :images, as: :imageable, dependent: :destroy
    belongs_to :cuisine_type
  
    acts_as_taggable_on :tags
  
    delegate :latitude, :longitude, to: :google_restaurant, allow_nil: true
  
    validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
    validates :price_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
    validates :business_status, inclusion: { in: ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'] }, allow_nil: true
  
    scope :favorites, -> { where(favorite: true) }
  
    pg_search_scope :search_by_full_text,
                    against: {
                      name: 'A',
                      notes: 'B'
                    },
                    associated_against: {
                      google_restaurant: {
                        name: 'A',
                        address: 'B',
                        city: 'C',
                        street: 'C'
                      }
                    },
                    using: {
                      tsearch: { prefix: true, dictionary: 'english' }
                    }
  
    scope :search_by_name_and_address, ->(query) {
      joins(:google_restaurant)
        .where("restaurants.name ILIKE :query OR restaurants.address ILIKE :query OR google_restaurants.name ILIKE :query OR google_restaurants.address ILIKE :query", query: "%#{query}%")
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
        .select('restaurants.*, ' + 
                GOOGLE_FALLBACK_ATTRIBUTES.map { |attr| 
                  "COALESCE(restaurants.#{attr}, google_restaurants.#{attr}) AS combined_#{attr}"
                }.join(', ') +
                ', restaurants.price_level AS restaurant_price_level, restaurants.rating AS restaurant_rating')
    end
  
    def self.near(center, distance, options = {})
      with_google.merge(GoogleRestaurant.near(center, distance, options))
    end
  
    def self.order_by_distance_from(location)
      with_google
        .joins(:google_restaurant)
        .merge(GoogleRestaurant.near(location, 20_000, units: :km))
        .select('restaurants.*, restaurants.name AS restaurant_name, google_restaurants.name AS google_restaurant_name')
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
      return nil unless combined_latitude && combined_longitude
      
      origin = [combined_latitude, combined_longitude]
      destination = [lat, lon]
      Geocoder::Calculations.distance_between(origin, destination)
    end
  
    def price_level_display
      '$' * price_level if price_level
    end  

end
