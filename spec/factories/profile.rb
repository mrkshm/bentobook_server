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

    trait :with_avatars do
      after(:build) do |profile|
        # Medium avatar
        profile.avatar_medium.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'avatar_medium.webp',
          content_type: 'image/webp'
        )
        
        # Thumbnail avatar
        profile.avatar_thumbnail.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'avatar_thumbnail.webp',
          content_type: 'image/webp'
        )
      end
    end
  end
end
