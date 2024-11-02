# frozen_string_literal: true

class CuisineTypeSelectComponent < ViewComponent::Base
    def initialize(form:, cuisine_types:)
      @form = form
      @cuisine_types = cuisine_types
    end
  
    def cuisine_types_json
      @cuisine_types.map do |ct| 
        { 
          id: ct.id, 
          name: ct.name,
          translated_name: ct.translated_name 
        }
      end.to_json
    end
  end
  