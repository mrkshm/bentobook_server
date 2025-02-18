# frozen_string_literal: true

module Shell
  class HamburgerButtonComponent < ViewComponent::Base
    def initialize(mobile_menu_id:)
      @mobile_menu_id = mobile_menu_id
    end

    private

    attr_reader :mobile_menu_id
  end
end
