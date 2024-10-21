FactoryBot.define do
  factory :refresh_token do
    user { nil }
    token { "MyString" }
    expires_at { "2024-10-19 17:35:13" }
    device_info { "MyString" }
  end
end
