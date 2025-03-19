module Bentobook
  SUPPORTED_CURRENCIES = [
    [ "USD", "EUR", "GBP", "CAD", "AUD", "JPY", "CHF" ].map do |code|
      currency = Money::Currency.find(code)
      [ "#{currency.name} (#{currency.iso_code})", currency.iso_code ]
    end
  ].freeze
end
