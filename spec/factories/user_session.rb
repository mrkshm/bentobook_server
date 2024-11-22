FactoryBot.define do
  factory :user_session do
    association :user
    jti { SecureRandom.uuid }
    client_name { "web" }
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" }
    active { true }
    last_used_at { Time.current }

    trait :mobile do
      user_agent { "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1" }
    end

    trait :tablet do
      user_agent { "Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1" }
    end

    trait :desktop do
      user_agent { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" }
    end

    trait :inactive do
      active { false }
    end
  end
end
