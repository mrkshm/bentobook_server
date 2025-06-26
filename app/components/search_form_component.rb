class SearchFormComponent < ApplicationComponent
  def initialize(url:, placeholder:, search_value:, additional_fields: {})
    @url = url
    @placeholder = placeholder
    @search_value = search_value
    @additional_fields = additional_fields
  end
end
