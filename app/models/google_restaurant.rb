class GoogleRestaurant < ApplicationRecord
  has_many :restaurants
  has_many :users, through: :restaurants

  validates :google_place_id, presence: true, uniqueness: true
  validates :name, :address, :city, presence: true
  validates :latitude, :longitude, presence: true, numericality: true
  validates :google_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :google_ratings_total, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
  # Business statuses as defined by Google Places API
  validates :business_status, inclusion: { in: ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'] }, allow_nil: true

  # Keep Geocoder with PostGIS
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode, if: ->(obj){ obj.latitude_changed? || obj.longitude_changed? }

  # These PostGIS scopes can work alongside Geocoder
  scope :order_by_distance_from, ->(lat, lon) { 
    near([lat, lon]).order("distance")
  }

  scope :nearby, ->(lat, lon, distance_in_meters = 50000) {
    near([lat, lon], distance_in_meters / 1000.0)
  }

  # Scope to preload location data
  scope :with_location, -> { select('google_restaurants.*, ST_AsText(location) as location_text') }

  # Get formatted coordinates
  def coordinates
    [latitude, longitude] if latitude.present? && longitude.present?
  end

  def needs_update?
    google_updated_at.nil? || google_updated_at < 30.days.ago
  end

  validate :google_place_id_not_undefined

  before_save :update_location, if: :coordinates_changed?

  private

  def google_place_id_not_undefined
    if google_place_id == "undefined"
      errors.add(:google_place_id, "cannot be undefined")
    end
  end

  def update_location
    return unless latitude.present? && longitude.present?
    self.location = "POINT(#{longitude} #{latitude})"
  rescue StandardError => e
    Rails.logger.error "Failed to update location: #{e.message}"
    errors.add(:location, "could not be updated")
    false
  end

  def coordinates_changed?
    latitude_changed? || longitude_changed?
  end
end
