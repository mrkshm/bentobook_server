module Shared
  class FlashIconComponent < ViewComponent::Base
    include HeroiconHelper

    ICONS = {
      notice: "information-circle",
      success: "check-circle",
      warning: "exclamation-triangle",
      error: "x-circle",
      alert: "x-circle"
    }.freeze

    def initialize(type:)
      @type = type.to_sym
      @icon = ICONS[@type] || ICONS[:notice]
    end

    private

    attr_reader :type, :icon
  end
end
