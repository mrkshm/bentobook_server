module CuisineTypeValidation
  extend ActiveSupport::Concern

  private

  def validate_cuisine_type(cuisine_type_name)
    Rails.logger.debug "=== DEBUG: Validating cuisine type: #{cuisine_type_name} ==="
    
    if cuisine_type_name.blank?
      available_categories = format_available_categories
      return [ false, "Cuisine type is required. Available categories: #{available_categories}" ]
    end

    cuisine_type = CuisineType.find_by(name: cuisine_type_name.downcase)
    Rails.logger.debug "Found cuisine type: #{cuisine_type.inspect}"
    
    unless cuisine_type
      available_categories = format_available_categories
      error_message = "Invalid cuisine type: #{cuisine_type_name}. Available categories: #{available_categories}"
      Rails.logger.debug "Error: #{error_message}"
      return [ false, error_message ]
    end

    [ true, cuisine_type ]
  end
  
  def format_available_categories
    categories = Category.includes(:cuisine_types).ordered
    
    categories.map do |category|
      cuisine_types = category.cuisine_types.order(:display_order).pluck(:name).join(', ')
      "#{category.name} (#{cuisine_types})"
    end.join('; ')
  end
  
  # Helper method to get all cuisine types grouped by category
  def grouped_cuisine_types
    CuisineType.includes(:category).group_by(&:category)
  end
end
