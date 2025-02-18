# frozen_string_literal: true

module Shell
  class MobileMenuComponent < ViewComponent::Base
    include Devise::Controllers::Helpers
    include ApplicationHelper

    def initialize(id:)
      @id = id
    end

    private

    attr_reader :id
  end
end
