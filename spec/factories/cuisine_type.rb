FactoryBot.define do
  factory :cuisine_type do
    sequence(:name) { |n| "Cuisine Type #{n}" }
  end
end
