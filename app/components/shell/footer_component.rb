# frozen_string_literal: true

module Shell
  class FooterComponent < ViewComponent::Base
    def initialize
    end

    def current_year
      Time.current.year
    end
  end
end
