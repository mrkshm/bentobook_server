FactoryBot.define do
    factory :contact do
      sequence(:name) { |n| "Contact #{n}" }
      email { "example@example.com" }
      city { "City" }
      country { "Country" }
      phone { "1234567890" }
      notes { "Some notes" }
      user
    end
  end
