FactoryBot.define do
  factory :cuisine_type do
    sequence(:name) do |n|
      CUISINE_TYPES[n % CUISINE_TYPES.length]
    end
  end

  # Define the list of valid cuisine types from seeds
  CUISINE_TYPES = %w[
    african american asian asian_fusion bakery bar bbq brazilian british
    brunch burger cafe caribbean chinese dim_sum ethiopian french fusion
    german greek indian italian japanese korean mediterranean mexican
    middle_eastern moroccan noodles other peruvian portuguese pub ramen
    seafood spanish steakhouse taiwanese thai turkish vegan vegetarian vietnamese
  ].freeze
end
