# frozen_string_literal: true

module Shared
  class ButtonComponent < ViewComponent::Base
    SIZES = {
      xs: "rounded-sm px-2 py-1 text-xs",
      sm: "rounded-sm px-2 py-1 text-sm",
      md: "rounded-md px-3 py-2 text-sm",
      lg: "rounded-md px-3.5 py-2.5 text-sm",
      xl: "rounded-lg px-4 py-3 text-base"
    }.freeze

    def initialize(type: :button, size: :md, **options)
      @type = type
      @size = size
      @options = options
    end

    private

    def button_classes
      [
        SIZES[@size],
        "bg-primary-600 font-semibold text-surface-50",
        "shadow-xs hover:bg-primary-500",
        "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-600"
      ].join(" ")
    end

    def html_options
      @options.merge(
        type: @type,
        class: [@options[:class], button_classes].compact.join(" ")
      )
    end
  end
end
