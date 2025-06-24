# == Schema Information
#
# Table name: list_restaurants
#
#  id            :bigint           not null, primary key
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  list_id       :bigint           not null
#  restaurant_id :bigint           not null
#
# Indexes
#
#  index_list_restaurants_on_list_id                    (list_id)
#  index_list_restaurants_on_list_id_and_restaurant_id  (list_id,restaurant_id) UNIQUE
#  index_list_restaurants_on_restaurant_id              (restaurant_id)
#
# Foreign Keys
#
#  fk_list_restaurants_list        (list_id => lists.id) ON DELETE => cascade
#  fk_list_restaurants_restaurant  (restaurant_id => restaurants.id) ON DELETE => cascade
#  fk_rails_...                    (list_id => lists.id)
#  fk_rails_...                    (restaurant_id => restaurants.id)
#
class ListRestaurant < ApplicationRecord
  belongs_to :list
  belongs_to :restaurant

  validates :list_id, uniqueness: { scope: :restaurant_id }
  acts_as_list scope: :list
end
