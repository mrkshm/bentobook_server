cuisine_types = [
  "African",
  "American",
  "Bar",
  "Brazilian",
  "Caribbean",
  "Chinese",
  "Ethiopian",
  "French",
  "German",
  "Greek",
  "Indian",
  "Italian",
  "Japanese",
  "Korean",
  "Lebanese",
  "Mediterranean",
  "Mexican",
  "Middle Eastern",
  "Moroccan",
  "Other",
  "Russian",
  "Seafood",
  "Spanish",
  "Thai",
  "Turkish",
  "Vietnamese",
  "Wine Bar"
]

ActiveRecord::Base.transaction do
  cuisine_types.each do |cuisine|
    CuisineType.find_or_create_by!(name: cuisine)
  end

  puts "Created #{CuisineType.count} cuisine types"

  # Get the "Other" cuisine type
  other_cuisine = CuisineType.find_by!(name: "Other")

  # Update existing restaurants without a cuisine type
  restaurants_updated = Restaurant.where(cuisine_type_id: nil).update_all(cuisine_type_id: other_cuisine.id)

  puts "Updated #{restaurants_updated} restaurants with 'Other' cuisine type"
end
