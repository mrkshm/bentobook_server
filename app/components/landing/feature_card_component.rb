# frozen_string_literal: true

module Landing
  class FeatureCardComponent < ViewComponent::Base
    def initialize(title:, description:)
      @title = title
      @description = description
    end

    private

    attr_reader :title, :description
  end
end
