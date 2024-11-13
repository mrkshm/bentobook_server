class ListRestaurant < ApplicationRecord
  belongs_to :list
  belongs_to :restaurant

  validates :list_id, uniqueness: { scope: :restaurant_id }
  acts_as_list scope: :list
end
