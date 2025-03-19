class Visit < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  belongs_to :restaurant
  has_many :visit_contacts
  has_many :contacts, through: :visit_contacts
  has_many :images, as: :imageable, dependent: :destroy

  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :date, presence: true

  monetize :price_paid_cents, with_currency: :price_paid_currency, allow_nil: true

  # Add search functionality
  pg_search_scope :search_by_full_text,
    against: {
      title: "A",
      notes: "B"
    },
    associated_against: {
      restaurant: {
        name: "A"
      },
      contacts: {
        name: "B"
      }
    },
    using: {
      tsearch: { prefix: true, dictionary: "english" }
    }
end
