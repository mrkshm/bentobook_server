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

    VARIANTS = {
      primary: "bg-primary-600 text-surface-50 hover:bg-primary-500",
      secondary: "bg-surface-50 text-surface-900 ring-1 ring-inset ring-surface-300 hover:bg-surface-100",
      danger: "bg-error-600 text-surface-50 hover:bg-error-500",
      ghost: "text-surface-900 hover:bg-surface-100"
    }.freeze

    def initialize(
      type: :button,
      size: :md,
      variant: :primary,
      confirm: false,
      confirm_message: nil,
      **options
    )
      @type = type
      @size = size
      @variant = variant
      @confirm = confirm
      @confirm_message = confirm_message
      @options = options
    end

    private

    def button_classes
      [
        SIZES[@size],
        VARIANTS[@variant],
        "font-semibold",
        "shadow-xs",
        "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary-600"
      ].join(" ")
    end

    def html_options
      options = @options.merge(
        type: @type,
        class: [ @options[:class], button_classes ].compact.join(" ")
      )

      if @confirm
        options[:data] ||= {}
        options[:data][:confirm] = @confirm_message || "Are you sure?"
      end

      options
    end
  end
end
