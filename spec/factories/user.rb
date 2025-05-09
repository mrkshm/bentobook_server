FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }
    first_name { "John" }
    last_name { "Doe" }
    theme { "light" }
    language { "en" }

    trait :with_lists do
      after(:create) do |user|
        organization = user.organizations.first
        create_list(:list, 2, organization: organization, creator: user)
      end
    end

    trait :with_shared_lists do
      after(:create) do |user|
        # Create a source organization that will share with the user's organization
        source_org = create(:organization)
        target_org = user.organizations.first
        
        # Create a list in the source organization
        creator = create(:user)
        create(:membership, user: creator, organization: source_org)
        list = create(:list, organization: source_org, creator: creator)
        
        # Share the list with the user's organization
        create(:share, source_organization: source_org, target_organization: target_org, 
               shareable: list, creator: creator, status: :accepted)
        create(:share, source_organization: source_org, target_organization: target_org, 
               shareable: list, creator: creator, status: :pending)
      end
    end

    # Renamed from with_created_shares to with_organization_shares to better reflect
    # that we're creating shares from the user's organization to another organization
    trait :with_organization_shares do
      after(:create) do |user|
        # User's organization is the source
        source_org = user.organizations.first
        target_org = create(:organization)
        
        # Create a list in the user's organization
        list = create(:list, organization: source_org, creator: user)
        
        # Share the list with another organization
        create_list(:share, 2, source_organization: source_org, target_organization: target_org, 
                   shareable: list, creator: user)
      end
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
