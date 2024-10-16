FactoryBot.define do
  factory :profile do
    user
    sequence(:username) { |n| "username#{n}" }
    first_name { "John" }
    last_name { "Doe" }
  end
end
