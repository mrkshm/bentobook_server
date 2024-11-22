FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end

    trait :with_restaurants do
      after(:create) do |user|
        create_list(:restaurant, 2, user: user)
      end
    end

    trait :with_visits do
      after(:create) do |user|
        create_list(:visit, 2, user: user)
      end
    end

    trait :with_lists do
      after(:create) do |user|
        create_list(:list, 2, owner: user)
      end
    end

    trait :with_shared_lists do
      after(:create) do |user|
        create(:share, recipient: user, status: :accepted)
        create(:share, recipient: user, status: :pending)
      end
    end

    trait :with_created_shares do
      after(:create) do |user|
        create_list(:share, 2, creator: user)
      end
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :with_contacts do
      after(:create) do |user|
        create_list(:contact, 2, user: user)
      end
    end

    after(:create) { |user| user.send(:ensure_profile) }
  end
end
