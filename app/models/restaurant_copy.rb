# == Schema Information
#
# Table name: restaurant_copies
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  copied_restaurant_id :bigint           not null
#  organization_id      :bigint           not null
#  restaurant_id        :bigint           not null
#
# Indexes
#
#  index_restaurant_copies_on_copied_restaurant_id               (copied_restaurant_id)
#  index_restaurant_copies_on_organization_id                    (organization_id)
#  index_restaurant_copies_on_organization_id_and_restaurant_id  (organization_id,restaurant_id) UNIQUE
#  index_restaurant_copies_on_restaurant_id                      (restaurant_id)
#
# Foreign Keys
#
#  fk_rails_...  (copied_restaurant_id => restaurants.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (restaurant_id => restaurants.id)
#
class RestaurantCopy < ApplicationRecord
  belongs_to :organization
  belongs_to :restaurant  # Original restaurant
  belongs_to :copied_restaurant, class_name: 'Restaurant'
  
  validates :organization_id, uniqueness: { scope: :restaurant_id }
end
