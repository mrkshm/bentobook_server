FactoryBot.define do
  factory :google_restaurant do
    sequence(:google_place_id) { |n| "PLACE_ID_#{n}" }
    sequence(:name) { |n| "Restaurant #{n}" }
    sequence(:address) { |n| "#{n} Test Street" }
    sequence(:city) { |n| "Test City #{n}" }
    latitude { 40.7128 }
    longitude { -74.0060 }
    google_rating { 4.5 }
    google_ratings_total { rand(10..1000) }
    price_level { rand(1..4) }
    business_status { [ 'OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY' ].sample }

    after(:build) do |restaurant|
      restaurant.location = "POINT(#{restaurant.longitude} #{restaurant.latitude})"
    end

    trait :without_coordinates do
      latitude { nil }
      longitude { nil }
      after(:build) do |gr|
        gr.define_singleton_method(:valid?) { true }
      end
    end
  end
end
