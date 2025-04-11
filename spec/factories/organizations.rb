FactoryBot.define do
  factory :organization do
    sequence(:username) { |n| "org#{n}" }
    sequence(:name) { |n| "Organization #{n}" }
    about { "A great organization" }

    trait :with_member do
      transient do
        member { create(:user) }
      end

      after(:create) do |organization, evaluator|
        create(:membership, organization: organization, user: evaluator.member)
      end
    end

    trait :with_avatars do
      after(:build) do |organization|
        # Medium avatar
        organization.avatar_medium.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'avatar_medium.webp',
          content_type: 'image/webp'
        )
        
        # Thumbnail avatar
        organization.avatar_thumbnail.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'avatar_thumbnail.webp',
          content_type: 'image/webp'
        )
      end
    end
  end
end
