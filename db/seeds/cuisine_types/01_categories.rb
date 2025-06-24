categories = [
  { name: "african", display_order: 1 },
  { name: "asian", display_order: 2 },
  { name: "european", display_order: 3 },
  { name: "eastern_european", display_order: 4 },
  { name: "middle_eastern", display_order: 5 },
  { name: "american", display_order: 6 },
  { name: "dietary", display_order: 7 },
  { name: "social", display_order: 8 },
  { name: "other", display_order: 9 }
]

ActiveRecord::Base.transaction do
  categories.each do |category_data|
    CuisineCategory.find_or_create_by!(name: category_data[:name]) do |category|
      category.display_order = category_data[:display_order]
    end
  end

  puts "Created #{CuisineCategory.count} cuisine categories"
end
