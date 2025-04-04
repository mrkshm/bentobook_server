FactoryBot.define do
    factory :contact do
      sequence(:name) { |n| "Contact #{n}" }
      sequence(:email) { |n| "example#{n}@example.com" }
      city { "City" }
      country { "Country" }
      phone { "1234567890" }
      notes { "Some notes" }
      organization
    end
  end
