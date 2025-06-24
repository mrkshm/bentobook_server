# == Schema Information
#
# Table name: google_restaurants
#
#  id                   :bigint           not null, primary key
#  address              :text
#  business_status      :string
#  city                 :string
#  country              :string
#  google_rating        :float
#  google_ratings_total :integer
#  google_updated_at    :datetime
#  latitude             :decimal(10, 8)
#  location             :geometry(Point,4
#  longitude            :decimal(11, 8)
#  name                 :string
#  opening_hours        :json
#  phone_number         :string
#  postal_code          :string
#  price_level          :integer
#  state                :string
#  street               :string
#  street_number        :string
#  url                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  google_place_id      :string
#
# Indexes
#
#  index_google_restaurants_on_address          (address)
#  index_google_restaurants_on_city             (city)
#  index_google_restaurants_on_google_place_id  (google_place_id) UNIQUE
#  index_google_restaurants_on_id               (id)
#  index_google_restaurants_on_location         (location) USING gist
#  index_google_restaurants_on_name             (name)
#
class GoogleRestaurant < ApplicationRecord
  has_many :restaurants
  has_many :organizations, through: :restaurants

  validates :google_place_id, presence: true, uniqueness: true
  validates :name, :address, :city, presence: true
  validates :latitude, :longitude, presence: true, numericality: true
  validates :google_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :google_ratings_total, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
  validates :business_status, inclusion: { in: ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'] }, allow_nil: true
  validate :google_place_id_not_undefined

  before_save :update_location, if: :coordinates_changed?

  # PostGIS scopes
  scope :nearby, ->(lat, lon, distance_in_meters = 50000) {
    where("ST_DWithin(location::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)", lon, lat, distance_in_meters)
  }

  scope :order_by_distance_from, ->(lat, lon) {
    select("*, ST_Distance(location::geography, ST_SetSRID(ST_MakePoint(#{lon}, #{lat}), 4326)::geography) as distance")
      .order('distance')
  }

  # Alias for consistency with Restaurant model
  class << self
    alias_method :near, :nearby
  end

  # Scope to preload location data
  scope :with_location, -> { select('google_restaurants.*, ST_AsText(location) as location_text') }

  # Get formatted coordinates
  def coordinates
    [latitude, longitude] if latitude.present? && longitude.present?
  end

  def needs_update?
    google_updated_at.nil? || google_updated_at < 30.days.ago
  end

  def coordinates_changed?
    latitude_changed? || longitude_changed?
  end

  def update_location
    if latitude.present? && longitude.present?
      self.location = ActiveRecord::Base.connection.execute(
        "SELECT ST_SetSRID(ST_MakePoint(#{longitude}, #{latitude}), 4326)"
      ).first['st_setsrid']
    else
      self.location = nil
    end
  rescue StandardError => e
    Rails.logger.error "Failed to update location: #{e.message}"
    errors.add(:location, "could not be updated")
    false
  end

  private

  def location_must_be_present
    if latitude.present? && longitude.present? && location.nil?
      errors.add(:location, "must be present when coordinates are set")
    end
  end

  def google_place_id_not_undefined
    if google_place_id == "undefined"
      errors.add(:google_place_id, "cannot be undefined")
    end
  end

  def self.find_or_create_from_google_data(data)
    return nil unless data && data[:google_place_id].present?

    restaurant = find_or_initialize_by(google_place_id: data[:google_place_id])
    
    # Update attributes if the restaurant needs an update
    if restaurant.new_record? || restaurant.needs_update?
      restaurant.assign_attributes({
        name: data[:name],
        address: data[:address],
        city: data[:city],
        latitude: data[:latitude],
        longitude: data[:longitude],
        google_rating: data[:google_rating],
        google_ratings_total: data[:google_ratings_total],
        price_level: data[:price_level],
        business_status: data[:business_status],
        google_updated_at: Time.current
      }.compact)

      restaurant.save!
    end

    restaurant
  end
end
