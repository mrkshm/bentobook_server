class SortFormComponent < ApplicationComponent
  def initialize(url:, sort_options:, current_field: nil, current_direction: "asc", additional_params: {})
    @url = url
    @sort_options = sort_options
    @current_field = current_field
    @current_direction = current_direction || "asc"
    @additional_params = additional_params
  end

  def opposite_direction
    @current_direction == "asc" ? "desc" : "asc"
  end
end
