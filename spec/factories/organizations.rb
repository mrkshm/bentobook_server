FactoryBot.define do
  factory :organization do
    trait :with_member do
      transient do
        member { create(:user) }
      end

      after(:create) do |organization, evaluator|
        create(:membership, organization: organization, user: evaluator.member)
      end
    end
  end
end
