FactoryBot.define do
  factory :list do
    organization
    creator { association :user }
    sequence(:name) { |n| "Test List #{n}" }
    description { "A test list description" }
    visibility { :personal }
    position { 1 }

    trait :with_restaurants do
      transient do
        restaurants_count { 3 }
      end

      after(:create) do |list, evaluator|
        create_list(:restaurant, evaluator.restaurants_count).each do |restaurant|
          create(:list_restaurant, list: list, restaurant: restaurant)
        end
      end
    end

    trait :discoverable do
      visibility { :discoverable }
    end

    trait :personal do
      visibility { :personal }
    end
  end
end