module CurrencySupport
  extend ActiveSupport::Concern

  # Map of country codes to currency symbols
  LOCALE_TO_CURRENCY = {
    "US" => "dollar",
    "JP" => "yen",
    "UK" => "ukp",
    "GB" => "ukp",
    "EU" => "euro",
    "IN" => "rupees"
  }.freeze

  # European countries that use the Euro
  EURO_COUNTRIES = %w[AT BE CY EE FI FR DE GR IE IT LV LT LU MT NL PT SK SI ES].freeze

  # Class-level helper so we can call CurrencySupport.currency_for_locale(...)
  def self.currency_for_locale(locale)
    country_code = locale.to_s.split("-").last.upcase

    # Check if it's a European country that uses the Euro
    return "euro" if EURO_COUNTRIES.include?(country_code)

    # Otherwise use the direct mapping or default to dollar
    LOCALE_TO_CURRENCY[country_code] || "dollar"
  end

  # Instance-level convenience wrapper (optional)
  def currency_for_locale(locale)
    self.class.currency_for_locale(locale)
  end

  def detect_and_set_currency(locale = I18n.locale)
    return preferred_currency_symbol if preferred_currency_symbol.present?

    currency = CurrencySupport.currency_for_locale(locale)
    update(preferred_currency_symbol: currency) if respond_to?(:update) && persisted?
    currency
  end
end
