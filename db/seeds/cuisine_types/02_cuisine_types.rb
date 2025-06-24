cuisine_types_by_category = {
  "african" => [
    { name: "african", display_order: 1 },
    { name: "ethiopian", display_order: 2 },
    { name: "moroccan", display_order: 3 },
    { name: "nigerian", display_order: 4 },
    { name: "south_african", display_order: 5 },
    { name: "ghanaian", display_order: 6 },
    { name: "senegalese", display_order: 7 },
    { name: "somali", display_order: 8 },
    { name: "eritrean", display_order: 9 },
    { name: "congolese", display_order: 10 },
    { name: "african_fusion", display_order: 11 }
  ],
  "asian" => [
    { name: "asian", display_order: 1 },
    { name: "chinese", display_order: 2 },
    { name: "japanese", display_order: 3 },
    { name: "indian", display_order: 4 },
    { name: "thai", display_order: 5 },
    { name: "korean", display_order: 6 },
    { name: "vietnamese", display_order: 7 },
    { name: "indonesian", display_order: 8 },
    { name: "malaysian", display_order: 9 },
    { name: "singaporean", display_order: 10 },
    { name: "filipino", display_order: 11 },
    { name: "sri_lankan", display_order: 12 },
    { name: "cambodian", display_order: 13 },
    { name: "laotian", display_order: 14 },
    { name: "taiwanese", display_order: 15 },
    { name: "mongolian", display_order: 16 },
    { name: "pakistani", display_order: 17 },
    { name: "bangladeshi", display_order: 18 },
    { name: "central_asian", display_order: 19 },
    { name: "tibetan_nepalese", display_order: 20 },
    { name: "burmese_myanmar", display_order: 21 },
    { name: "asian_fusion", display_order: 22 }
  ],
  "european" => [
    { name: "european", display_order: 1 },
    { name: "italian", display_order: 2 },
    { name: "french", display_order: 3 },
    { name: "spanish", display_order: 4 },
    { name: "greek", display_order: 5 },
    { name: "portuguese", display_order: 6 },
    { name: "british", display_order: 7 },
    { name: "german", display_order: 8 },
    { name: "austrian", display_order: 9 },
    { name: "mediterranean", display_order: 10 },
    { name: "scandinavian", display_order: 11 },
    { name: "jewish", display_order: 12 },
    { name: "swiss", display_order: 13 },
    { name: "belgian", display_order: 14 },
    { name: "dutch", display_order: 15 },
    { name: "flemish", display_order: 16 },
    { name: "european_fusion", display_order: 17 }
  ],
  "eastern_european" => [
    { name: "eastern_european", display_order: 1 },
    { name: "polish", display_order: 2 },
    { name: "hungarian", display_order: 3 },
    { name: "ukrainian", display_order: 4 },
    { name: "romanian", display_order: 5 },
    { name: "bulgarian", display_order: 6 },
    { name: "balkan", display_order: 7 },
    { name: "georgian", display_order: 8 },
    { name: "armenian", display_order: 9 },
    { name: "baltic", display_order: 10 },
    { name: "czech_slovak", display_order: 11 },
    { name: "russian", display_order: 12 },
    { name: "eastern_european_fusion", display_order: 13 }
  ],
  "american" => [
    { name: "american", display_order: 1 },
    { name: "usa", display_order: 2 },
    { name: "mexican", display_order: 3 },
    { name: "southern", display_order: 4 },
    { name: "brazilian", display_order: 5 },
    { name: "caribbean", display_order: 6 },
    { name: "argentinean", display_order: 7 },
    { name: "peruvian", display_order: 8 },
    { name: "chilean", display_order: 9 },
    { name: "colombian", display_order: 10 },
    { name: "venezuelan", display_order: 11 },
    { name: "american_fusion", display_order: 12 },
    { name: "latin_american_fusion", display_order: 13 }
  ],
  "middle_eastern" => [
    { name: "middle_eastern", display_order: 1 },
    { name: "turkish", display_order: 2 },
    { name: "persian", display_order: 3 },
    { name: "lebanese", display_order: 4 },
    { name: "north_african", display_order: 5 },
    { name: "arabic", display_order: 6 },
    { name: "syrian", display_order: 7 },
    { name: "egyptian", display_order: 8 },
    { name: "iraqi", display_order: 9 },
    { name: "gulf", display_order: 10 },
    { name: "yemeni", display_order: 11 },
    { name: "israeli", display_order: 12 },
    { name: "levantine", display_order: 13 },
    { name: "middle_eastern_fusion", display_order: 14 }
  ],
  "dietary" => [
    { name: "dietary", display_order: 1 },
    { name: "vegetarian", display_order: 2 },
    { name: "vegan", display_order: 3 },
    { name: "gluten_free", display_order: 4 },
    { name: "keto", display_order: 5 },
    { name: "paleo", display_order: 6 }
  ],
  "social" => [
    { name: "social", display_order: 1 },
    { name: "cafe", display_order: 2 },
    { name: "bar", display_order: 3 },
    { name: "wine_bar", display_order: 4 },
    { name: "pub", display_order: 5 },
    { name: "brewery", display_order: 6 },
    { name: "fast_food", display_order: 7 }
  ],
  "other" => [
    { name: "other", display_order: 1 }
  ]
}

ActiveRecord::Base.transaction do
  CuisineType.destroy_all

  cuisine_types_by_category.each do |category_name, cuisine_types|
    category = CuisineCategory.find_by!(name: category_name)
    cuisine_types.each do |cuisine_type_data|
      category.cuisine_types.create!(cuisine_type_data)
    end
  end

  puts "Created #{CuisineType.count} cuisine types"

  if Restaurant.any?
    other_cuisine_type = CuisineType.find_by!(name: "other")
    Restaurant.update_all(cuisine_type_id: other_cuisine_type.id)
    puts "Updated all restaurants to have cuisine type 'other'"
  end
end
