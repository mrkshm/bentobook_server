cuisine_types = [
  "african",
  "american",
  "asian_fusion",
  "bakery",
  "bar",
  "bbq",
  "brazilian",
  "british",
  "brunch",
  "burger",
  "cafe",
  "caribbean",
  "chinese",
  "dim_sum",
  "ethiopian",
  "french",
  "fusion",
  "german",
  "greek",
  "indian",
  "italian",
  "japanese",
  "korean",
  "mediterranean",
  "mexican",
  "middle_eastern",
  "moroccan",
  "noodles",
  "other",
  "peruvian",
  "portuguese",
  "pub",
  "ramen",
  "seafood",
  "spanish",
  "steakhouse",
  "taiwanese",
  "thai",
  "turkish",
  "vegan",
  "vegetarian",
  "vietnamese"
]

ActiveRecord::Base.transaction do
  cuisine_types.each do |cuisine|
    CuisineType.find_or_create_by!(name: cuisine)
  end

  puts "Created #{CuisineType.count} cuisine types"

  # Get the "Other" cuisine type
  other_cuisine = CuisineType.find_by!(name: "other")

  # Update existing restaurants without a cuisine type
  restaurants_updated = Restaurant.where(cuisine_type_id: nil).update_all(cuisine_type_id: other_cuisine.id)

  puts "Updated #{restaurants_updated} restaurants with 'Other' cuisine type"
end
