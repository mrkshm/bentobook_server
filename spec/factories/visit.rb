FactoryBot.define do
  factory :visit do
    user
    restaurant
    date { Date.today }
    title { "Visit to Restaurant" }
    notes { "Had a great time" }
    rating { rand(1..5) }
    price_paid_cents { rand(1000..10000) }
    price_paid_currency { 'USD' }

    trait :with_image do
      after(:create) do |visit|
        create(:image, imageable: visit)
      end
    end

    trait :with_contact do
      after(:create) do |visit|
        create(:visit_contact, visit: visit)
      end
    end

    trait :without_rating do
      rating { nil }
    end

    trait :without_price do
      price_paid_cents { nil }
      price_paid_currency { nil }
    end

    trait :with_multiple_contacts do
      after(:create) do |visit|
        create_list(:visit_contact, 3, visit: visit)
      end
    end

    trait :with_full_associations do
      after(:create) do |visit|
        create(:image, imageable: visit)
        create(:contact)
        visit.contacts << Contact.last
      end
    end
  end
end
