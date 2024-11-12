FactoryBot.define do
  factory :share do
    association :creator, factory: :user
    association :recipient, factory: :user
    association :shareable, factory: :list, traits: [:restricted]
    status { :accepted }
    permission { :view }
    
    trait :pending do
      status { :pending }
    end
    
    trait :rejected do
      status { :rejected }
    end
    
    trait :with_edit_permission do
      permission { :edit }
    end
  end
end
