module CuisineTypeValidation
  extend ActiveSupport::Concern

  private

  def validate_cuisine_type(cuisine_type_name)
    if cuisine_type_name.blank?
      available_types = CuisineType.pluck(:name).join(", ")
      return [ false, "Cuisine type is required. Available types: #{available_types}" ]
    end

    cuisine_type = CuisineType.find_by(name: cuisine_type_name.downcase)
    unless cuisine_type
      available_types = CuisineType.pluck(:name).join(", ")
      error_message = "Invalid cuisine type: #{cuisine_type_name}. Available types: #{available_types}"
      return [ false, error_message ]
    end

    [ true, cuisine_type ]
  end
end
