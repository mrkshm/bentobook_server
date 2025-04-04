class RestaurantCopy < ApplicationRecord
  belongs_to :organization
  belongs_to :restaurant  # Original restaurant
  belongs_to :copied_restaurant, class_name: 'Restaurant'
  
  validates :organization_id, uniqueness: { scope: :restaurant_id }
end
