FactoryBot.define do
  factory :user_session do
    association :user
    client_name { "web" }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0" }
    active { true }
  end
end
