cuisine_types_by_category = {
  "African" => [
    { name: "african", display_order: 1 },
    { name: "ethiopian", display_order: 2 },
    { name: "eritrean", display_order: 3 },
    { name: "senegalese", display_order: 4 },
    { name: "moroccan", display_order: 5 },
    { name: "south_african", display_order: 6 },
    { name: "african_fusion", display_order: 7 }
  ],
  "Asian" => [
    { name: "asian", display_order: 1 },
    { name: "chinese", display_order: 2 },
    { name: "japanese", display_order: 3 },
    { name: "korean", display_order: 4 },
    { name: "thai", display_order: 5 },
    { name: "vietnamese", display_order: 6 },
    { name: "indian", display_order: 7 },
    { name: "taiwanese", display_order: 8 },
    { name: "asian_fusion", display_order: 9 }
  ],
  "European" => [
    { name: "european", display_order: 1 },
    { name: "french", display_order: 2 },
    { name: "italian", display_order: 3 },
    { name: "spanish", display_order: 4 },
    { name: "greek", display_order: 5 },
    { name: "german", display_order: 6 },
    { name: "polish", display_order: 7 },
    { name: "hungarian", display_order: 8 },
    { name: "russian", display_order: 9 },
    { name: "austrian", display_order: 10 },
    { name: "swiss", display_order: 11 },
    { name: "british", display_order: 12 },
    { name: "portuguese", display_order: 13 },
    { name: "mediterranean", display_order: 14 },
    { name: "scandinavian", display_order: 15 },
    { name: "european_fusion", display_order: 16 }
  ],
  "American" => [
    { name: "american", display_order: 1 },
    { name: "us", display_order: 2 },
    { name: "southern", display_order: 3 },
    { name: "bbq", display_order: 4 },
    { name: "soul_food", display_order: 5 },
    { name: "mexican", display_order: 6 },
    { name: "brazilian", display_order: 7 },
    { name: "peruvian", display_order: 8 },
    { name: "cajun", display_order: 9 },
    { name: "american_fusion", display_order: 10 }
  ],
  "Middle Eastern" => [
    { name: "middle_eastern", display_order: 1 },
    { name: "lebanese", display_order: 2 },
    { name: "turkish", display_order: 3 },
    { name: "israeli", display_order: 4 },
    { name: "persian", display_order: 5 },
    { name: "arabic", display_order: 6 },
    { name: "middle_eastern_fusion", display_order: 7 }
  ],
  "Special" => [
    { name: "special", display_order: 1 },
    { name: "vegetarian", display_order: 2 },
    { name: "vegan", display_order: 3 },
    { name: "keto", display_order: 4 },
    { name: "paleo", display_order: 5 },
    { name: "gluten_free", display_order: 6 },
    { name: "special_fusion", display_order: 7 }
  ],
  "Dining Type" => [
    { name: "dining_type", display_order: 1 },
    { name: "cafe", display_order: 2 },
    { name: "wine_bar", display_order: 3 },
    { name: "pub", display_order: 4 },
    { name: "brewery", display_order: 5 },
    { name: "fast_food", display_order: 6 },
    { name: "dining_fusion", display_order: 7 }
  ],
  "Other" => [
    { name: "other", display_order: 1 }
  ]
}

ActiveRecord::Base.transaction do
  # First, clear out all existing cuisine types that aren't associated with restaurants
  CuisineType.includes(:restaurants).where(restaurants: { id: nil }).destroy_all
  puts "Removed unused cuisine types"
  
  cuisine_types_by_category.each do |category_name, cuisine_types|
    category = Category.find_by!(name: category_name)
    
    cuisine_types.each do |cuisine_type_data|
      CuisineType.find_or_create_by!(name: cuisine_type_data[:name]) do |cuisine_type|
        cuisine_type.category = category
        cuisine_type.display_order = cuisine_type_data[:display_order]
      end
    end
  end
  
  puts "Created #{CuisineType.count} cuisine types"
  
  # Get the "Other" cuisine type
  other_cuisine = CuisineType.find_by!(name: "other")
  
  # Update existing restaurants without a cuisine type
  restaurants_updated = Restaurant.where(cuisine_type_id: nil).update_all(cuisine_type_id: other_cuisine.id)
  
  puts "Updated #{restaurants_updated} restaurants with 'Other' cuisine type"
  
  # Map old cuisine types to new ones
  cuisine_type_mapping = {
    'african' => 'african_fusion',
    'asian' => 'asian_fusion',
    'asian_fusion' => 'asian_fusion',
    'bakery' => 'cafe',
    'bar' => 'pub',
    'brunch' => 'cafe',
    'burger' => 'fast_food',
    'caribbean' => 'american_fusion',
    'dim_sum' => 'chinese',
    'fusion' => 'special_fusion',
    'middle_eastern' => 'middle_eastern_fusion',
    'noodles' => 'asian_fusion',
    'ramen' => 'japanese',
    'seafood' => 'european_fusion',
    'steakhouse' => 'american_fusion',
    'turkish' => 'turkish',
    # Keeping: taiwanese, portuguese, peruvian, mediterranean
  }
  
  # Update restaurants with mapped cuisine types
  cuisine_type_mapping.each do |old_name, new_name|
    old_cuisine = CuisineType.find_by(name: old_name)
    next unless old_cuisine && old_cuisine.restaurants.any?
    
    new_cuisine = CuisineType.find_by(name: new_name)
    if new_cuisine
      count = Restaurant.where(cuisine_type_id: old_cuisine.id).update_all(cuisine_type_id: new_cuisine.id)
      puts "Updated #{count} restaurants from '#{old_name}' to '#{new_name}'"
    end
  end
end