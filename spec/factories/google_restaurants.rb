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
FactoryBot.define do
  factory :google_restaurant do
    sequence(:google_place_id) { |n| "place_id_#{n}" }
    sequence(:name) { |n| "Restaurant #{n}" }
    address { "123 Main St" }
    city { "San Francisco" }
    latitude { 37.7749 }
    longitude { -122.4194 }
    google_rating { 4.5 }
    google_ratings_total { 100 }
    price_level { 2 }
    business_status { "OPERATIONAL" }
    google_updated_at { 1.day.ago }

    trait :needs_update do
      google_updated_at { 31.days.ago }
    end

    trait :with_location do
      after(:build) do |restaurant|
        restaurant.location = ActiveRecord::Base.connection.execute(
          "SELECT ST_SetSRID(ST_MakePoint(#{restaurant.longitude}, #{restaurant.latitude}), 4326)"
        ).first['st_setsrid']
      end
    end

    trait :without_coordinates do
      latitude { nil }
      longitude { nil }
      location { nil }
    end
  end
end
