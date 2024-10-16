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

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode, if: ->(obj){ obj.latitude_changed? || obj.longitude_changed? }

  scope :order_by_distance_from, ->(location) { 
    near(location, 20_000, units: :km)
  }

  def needs_update?
    google_updated_at.nil? || google_updated_at < 30.days.ago
  end


end
