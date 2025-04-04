FactoryBot.define do
  factory :restaurant_copy do
    organization
    association :restaurant
    association :copied_restaurant, factory: :restaurant
  end
end
