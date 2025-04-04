FactoryBot.define do
  factory :restaurant do
    organization
    sequence(:name) { |n| "Custom Restaurant #{n}" }
    association :cuisine_type

    after(:build) do |restaurant|
      # Create a new google_restaurant only if one isn't already assigned
      restaurant.google_restaurant ||= build(:google_restaurant,
        name: restaurant.name,
        google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}"
      )
    end

    rating { rand(0..5) }
    price_level { rand(0..4) }
    business_status { [ 'OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY' ].sample }
    favorite { [ true, false ].sample }
    notes { "Some notes about the restaurant" }
    phone_number { "+1 555-#{rand(100..999)}-#{rand(1000..9999)}" }
    url { "https://example#{rand(1..100)}.com" }

    association :google_restaurant, :with_location

    trait :with_visits do
      transient do
        visit_count { 2 }
      end

      after(:create) do |restaurant, evaluator|
        create_list(:visit, evaluator.visit_count, restaurant: restaurant)
      end
    end

    trait :with_images do
      transient do
        image_count { 2 }
      end

      after(:create) do |restaurant, evaluator|
        evaluator.image_count.times do
          restaurant.images.create!(
            file: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg'))
          )
        end
      end
    end

    trait :with_manual_location do
      after(:build) do |restaurant|
        restaurant.google_restaurant.location = ActiveRecord::Base.connection.execute(
          "SELECT ST_SetSRID(ST_MakePoint(#{restaurant.google_restaurant.longitude}, #{restaurant.google_restaurant.latitude}), 4326)"
        ).first['st_setsrid']
      end
    end

    trait :with_copies do
      transient do
        copies_count { 2 }
        target_organization { create(:organization) }
      end

      after(:create) do |restaurant, evaluator|
        evaluator.copies_count.times do
          copy = create(:restaurant, 
            organization: evaluator.target_organization,
            original_restaurant: restaurant
          )
          create(:restaurant_copy,
            organization: evaluator.target_organization,
            restaurant: restaurant,
            copied_restaurant: copy
          )
        end
      end
    end

    trait :as_copy do
      association :original_restaurant, factory: :restaurant
      after(:create) do |restaurant|
        create(:restaurant_copy,
          organization: restaurant.organization,
          restaurant: restaurant.original_restaurant,
          copied_restaurant: restaurant
        )
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

    trait :in_list do
      transient do
        list { create(:list) }
      end

      after(:create) do |restaurant, evaluator|
        create(:list_restaurant, restaurant: restaurant, list: evaluator.list)
      end
    end
  end
end
