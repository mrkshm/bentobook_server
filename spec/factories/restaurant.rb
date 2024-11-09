FactoryBot.define do
  factory :restaurant do
    user
    association :google_restaurant, factory: :google_restaurant
    association :cuisine_type
    sequence(:name) { |n| "Restaurant #{n}" }
    sequence(:address) { |n| "#{n} Test Street, Test City" }
    rating { rand(0..5) }
    price_level { rand(0..4) }
    business_status { ['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY'].sample }
    favorite { [true, false].sample }
    notes { "Some notes about the restaurant" }

    trait :with_visits do
      after(:create) do |restaurant|
        create_list(:visit, 2, restaurant: restaurant)
      end
    end

    trait :with_images do
      after(:create) do |restaurant|
        include ActionDispatch::TestProcess
        2.times do
          restaurant.images.create!(
            file: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg'))
          )
        end
      end
    end

    trait :for_create do
      google_restaurant { nil }
      transient do
        google_place_id { "PLACE_ID_#{SecureRandom.hex(8)}" }
      end

      after(:build) do |restaurant, evaluator|
        restaurant.google_place_id = evaluator.google_place_id
      end
    end
  end
end
