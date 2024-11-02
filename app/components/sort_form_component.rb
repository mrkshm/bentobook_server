class SortFormComponent < ApplicationComponent
  def initialize(url:, fields:, current_order:, current_direction:, additional_fields: {})
    @url = url
    @fields = fields
    @current_order = current_order
    @current_direction = current_direction
    @additional_fields = additional_fields
  end
end
