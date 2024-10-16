FactoryBot.define do
    factory :contact do
      user
      name { "John Doe" }
      email { "john@example.com" }
    end
  end