# frozen_string_literal: true

class CuisineTypeSelectComponent < ViewComponent::Base
    def initialize(form:, cuisine_types:)
      @form = form
      @cuisine_types = cuisine_types
      @readonly = readonly
    end

    def cuisine_types_json
      @cuisine_types.map do |ct|
        {
          id: ct.id,
          name: ct.translated_name,
          value: ct.name
        }
      end.to_json
    end
end
