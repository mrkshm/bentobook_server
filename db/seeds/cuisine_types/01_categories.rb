categories = [
  { name: "African", display_order: 1 },
  { name: "Asian", display_order: 2 },
  { name: "European", display_order: 3 },
  { name: "American", display_order: 4 },
  { name: "Middle Eastern", display_order: 5 },
  { name: "Special", display_order: 6 },
  { name: "Dining Type", display_order: 7 },
  { name: "Other", display_order: 8 }
]

ActiveRecord::Base.transaction do
  categories.each do |category_data|
    Category.find_or_create_by!(name: category_data[:name]) do |category|
      category.display_order = category_data[:display_order]
    end
  end
  
  puts "Created #{Category.count} categories"
end