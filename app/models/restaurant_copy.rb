class RestaurantCopy < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant  # Original restaurant
  belongs_to :copied_restaurant, class_name: 'Restaurant'
  
  validates :user_id, uniqueness: { scope: :restaurant_id }
end
