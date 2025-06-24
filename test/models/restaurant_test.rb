# == Schema Information
#
# Table name: restaurants
#
#  id                     :bigint           not null, primary key
#  address                :text
#  business_status        :string
#  city                   :string
#  country                :string
#  favorite               :boolean          default(FALSE)
#  latitude               :decimal(10, 8)
#  longitude              :decimal(11, 8)
#  name                   :string
#  notes                  :text
#  opening_hours          :json
#  phone_number           :string
#  postal_code            :string
#  price_level            :integer
#  rating                 :integer
#  state                  :string
#  street                 :string
#  street_number          :string
#  tsv                    :tsvector
#  url                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  cuisine_type_id        :bigint
#  google_restaurant_id   :bigint
#  organization_id        :bigint
#  original_restaurant_id :bigint
#
# Indexes
#
#  index_restaurants_on_address                 (address)
#  index_restaurants_on_city                    (city)
#  index_restaurants_on_cuisine_type_id         (cuisine_type_id)
#  index_restaurants_on_favorite                (favorite)
#  index_restaurants_on_google_restaurant_id    (google_restaurant_id)
#  index_restaurants_on_name                    (name)
#  index_restaurants_on_notes                   (notes)
#  index_restaurants_on_organization_id         (organization_id)
#  index_restaurants_on_original_restaurant_id  (original_restaurant_id)
#  restaurants_tsv_idx                          (tsv) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (cuisine_type_id => cuisine_types.id)
#  fk_rails_...  (google_restaurant_id => google_restaurants.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (original_restaurant_id => restaurants.id)
#
require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
