FactoryBot.define do
  factory :visit do
    user
    restaurant
    date { Date.today }
    title { "Visit to Restaurant" }
    notes { "Had a great time" }
    rating { rand(1..5) }
  end
end