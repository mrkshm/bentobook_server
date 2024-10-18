FactoryBot.define do
  factory :profile do
    user
    sequence(:username) { |n| "username#{n}" }
    first_name { "John" }
    last_name { "Doe" }

    trait :with_full_name do
      username { nil }
    end
  end
end
