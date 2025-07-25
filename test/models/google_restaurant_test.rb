# == Schema Information
#
# Table name: google_restaurants
#
#  id                   :bigint           not null, primary key
#  address              :text
#  business_status      :string
#  city                 :string
#  country              :string
#  google_rating        :float
#  google_ratings_total :integer
#  google_updated_at    :datetime
#  latitude             :decimal(10, 8)
#  location             :geometry(Point,4
#  longitude            :decimal(11, 8)
#  name                 :string
#  opening_hours        :json
#  phone_number         :string
#  postal_code          :string
#  price_level          :integer
#  state                :string
#  street               :string
#  street_number        :string
#  url                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  google_place_id      :string
#
# Indexes
#
#  index_google_restaurants_on_address          (address)
#  index_google_restaurants_on_city             (city)
#  index_google_restaurants_on_google_place_id  (google_place_id) UNIQUE
#  index_google_restaurants_on_id               (id)
#  index_google_restaurants_on_location         (location) USING gist
#  index_google_restaurants_on_name             (name)
#
require "test_helper"

class GoogleRestaurantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
