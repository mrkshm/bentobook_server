FactoryBot.define do
  factory :google_restaurant do
    sequence(:google_place_id) { |n| "PLACE_ID_#{n}" }
    sequence(:name) { |n| "Google Restaurant #{n}" }
    address { "123 Main St" }
    city { "Anytown" }
    latitude { 40.7128 }
    longitude { -74.0060 }
    google_rating { rand(0.0..5.0).round(1) }
    google_ratings_total { rand(0..1000) }
    price_level { rand(0..4) }
    business_status { ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'].sample }
    
    # Skip callbacks
    to_create { |instance| instance.save(validate: false) }
  end
end
