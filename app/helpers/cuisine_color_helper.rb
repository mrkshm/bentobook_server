module CuisineColorHelper
  def category_color_classes(category, selected: false)
    base = "px-3 py-1.5 rounded-full text-sm"
    variant = selected ? "ring-2 ring-category-#{category.name.underscore}" : "hover:bg-category-#{category.name.underscore}-hover"

    "#{base} bg-category-#{category.name.underscore}-light text-category-#{category.name.underscore}-dark #{variant}"
  end

  def type_color_classes(cuisine_type, selected: false, readonly: false)
    # Use the same colors as the parent category
    category = cuisine_type.cuisine_category
    base = "mb-2 mr-1 px-3 py-1.5 rounded-full text-sm"
    variant = if selected
      "ring-2 ring-category-#{category.name.underscore}"
    elsif !readonly
      "hover:bg-category-#{category.name.underscore}-hover"
    else
      ""
    end

    "#{base} bg-category-#{category.name.underscore}-light text-category-#{category.name.underscore}-dark #{variant}"
  end
end
