class GoogleRestaurant < ApplicationRecord
  validates :google_place_id, presence: true, uniqueness: true
  validates :name, presence: true

end
