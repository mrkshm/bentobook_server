# frozen_string_literal: true

module CurrencySymbolHelper
  include Heroicon::Engine.helpers

  CURRENCY_TO_ICON = {
    "dollar" => "currency-dollar",
    "euro" => "currency-euro",
    "yen" => "currency-yen",
    "ukp" => "currency-pound",
    "rupees" => "currency-rupee"
  }.freeze

  def currency_icon(currency = nil, size: :md, **options)
    # If currency is not provided, use the organization's preferred currency
    if currency.nil? && Current.organization
      # Use the stored preferred currency if available
      currency = Current.organization.preferred_currency_symbol

      # If currency is still nil, detect and save it
      if currency.blank?
        # Try to detect from browser locale if available
        if defined?(request) && request&.env["HTTP_ACCEPT_LANGUAGE"].present?
          browser_locale = request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}\-[A-Z]{2}/).first
          currency = Current.organization.detect_and_set_currency(browser_locale) if browser_locale.present?
        else
          # Fall back to I18n.locale
          currency = Current.organization.detect_and_set_currency(I18n.locale)
        end
      end
    end

    icon_name = CURRENCY_TO_ICON[currency] || "currency-dollar"
    size_classes = {
      sm: "h-3 w-3",
      md: "h-6 w-6",
      lg: "h-8 w-8",
      xl: "h-12 w-12"
    }.freeze

    base_class   = size_classes.fetch(size, size_classes[:md])
    extra_class  = options.delete(:class)
    classes      = [ base_class, extra_class ].compact.join(" ")

    heroicon(icon_name, options: options.merge(class: classes))
  end
end
