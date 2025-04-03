class Visit < ApplicationRecord
  include PgSearch::Model

  belongs_to :organization
  belongs_to :restaurant
  has_many :visit_contacts, dependent: :destroy
  has_many :contacts, through: :visit_contacts
  has_many :images, as: :imageable, dependent: :destroy

  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :date, presence: true
  validates :time_of_day, presence: true

  def local_datetime
    return nil unless date && time_of_day

    # Combine date and time in user's timezone
    Time.zone.local(
      date.year,
      date.month,
      date.day,
      time_of_day.hour,
      time_of_day.min
    )
  end

  def time_of_day
    return nil unless super
    super.in_time_zone(Time.zone)
  end

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
