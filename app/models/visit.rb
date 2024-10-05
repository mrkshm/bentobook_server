class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  monetize :price_paid_cents, with_currency: :price_paid_currency, allow_nil: true
end
