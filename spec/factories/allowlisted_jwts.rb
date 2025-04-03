FactoryBot.define do
  factory :allowlisted_jwt do
    jti { "MyString" }
    exp { "2025-04-03 22:09:29" }
    user { nil }
    metadata { "" }
  end
end
