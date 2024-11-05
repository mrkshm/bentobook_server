FactoryBot.define do
  factory :profile do
    user
    sequence(:username) { |n| "username#{n}" }
    first_name { "John" }
    last_name { "Doe" }
    preferred_theme { "light" }
    preferred_language { "en" }

    trait :with_full_name do
      username { nil }
    end

    trait :with_avatar do
      after(:build) do |profile|
        profile.avatar.attach(
          io: File.open(Rails.root.join('spec/fixtures/avatar.jpg')),
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
