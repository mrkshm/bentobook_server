FactoryBot.define do
  factory :share do
    association :creator, factory: :user
    association :source_organization, factory: :organization
    association :target_organization, factory: :organization
    association :shareable, factory: :list
    status { :accepted }
    permission { :view }
    reshareable { true }
    
    trait :pending do
      status { :pending }
    end
    
    trait :rejected do
      status { :rejected }
    end
    
    trait :with_edit_permission do
      permission { :edit }
    end

    trait :not_reshareable do
      reshareable { false }
    end
  end
end
