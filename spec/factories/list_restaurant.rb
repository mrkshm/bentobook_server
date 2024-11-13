FactoryBot.define do
    factory :list_restaurant do
      list
      restaurant
      sequence(:position) { |n| n }
    end
end