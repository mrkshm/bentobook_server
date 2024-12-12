class GoogleRestaurant < ApplicationRecord
  has_many :restaurants
  has_many :users, through: :restaurants

  validates :google_place_id, presence: true, uniqueness: true
  validates :name, :address, :city, presence: true
  validates :latitude, :longitude, presence: true, numericality: true
  validates :google_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, allow_nil: true
  validates :google_ratings_total, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :price_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }, allow_nil: true
  validates :business_status, inclusion: { in: ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'] }, allow_nil: true

  # PostGIS scopes
  scope :order_by_distance_from, ->(lat, lon) { 
    select("#{table_name}.*, ST_Distance(#{table_name}.location, ST_SetSRID(ST_MakePoint(#{lon}, #{lat}), 4326)) as distance")
    .order('distance')
  }

  scope :nearby, ->(lat, lon, distance_in_meters = 50000) {
    where("ST_DWithin(#{table_name}.location::geography, ST_SetSRID(ST_MakePoint(#{lon}, #{lat}), 4326)::geography, #{distance_in_meters})")
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

  def self.find_or_initialize_by_place_id(attributes)
    return nil unless attributes && attributes[:google_place_id].present?

    existing = find_by(google_place_id: attributes[:google_place_id])
    if existing
      # Update existing record with new data if it needs update
      existing.assign_attributes(attributes) if existing.needs_update?
      existing
    else
      new(attributes)
    end
  end

  private

  def google_place_id_not_undefined
    if google_place_id == "undefined"
      errors.add(:google_place_id, "cannot be undefined")
    end
  end

  def update_location
    if latitude.present? && longitude.present?
      self.location = "POINT(#{longitude} #{latitude})"
    else
      self.location = nil
    end
  rescue StandardError => e
    Rails.logger.error "Failed to update location: #{e.message}"
    errors.add(:location, "could not be updated")
    false
  end

  def coordinates_changed?
    latitude_changed? || longitude_changed?
  end
end
