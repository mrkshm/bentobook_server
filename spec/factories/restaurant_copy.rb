FactoryBot.define do
  factory :restaurant_copy do
    user
    association :restaurant
    association :copied_restaurant, factory: :restaurant
  end
end
