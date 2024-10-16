# frozen_string_literal: true

class TagInputComponent < ViewComponent::Base
    def initialize(tags: [], input_name: "tag_list")
      @tags = tags
      @input_name = input_name
    end
  
    private
  
    attr_reader :tags, :input_name
end