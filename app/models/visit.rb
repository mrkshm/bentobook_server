class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant
  has_many :visit_contacts
  has_many :contacts, through: :visit_contacts
  has_many :images, as: :imageable, dependent: :destroy

  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true

  monetize :price_paid_cents, with_currency: :price_paid_currency, allow_nil: true
end
