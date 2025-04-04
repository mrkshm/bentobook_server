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
