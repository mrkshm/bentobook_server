# == Schema Information
#
# Table name: visits
#
#  id                  :bigint           not null, primary key
#  date                :date
#  notes               :text
#  price_paid_cents    :integer
#  price_paid_currency :string
#  rating              :integer
#  time_of_day         :time             not null
#  title               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organization_id     :bigint           not null
#  restaurant_id       :bigint           not null
#
# Indexes
#
#  index_visits_on_organization_id  (organization_id)
#  index_visits_on_restaurant_id    (restaurant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (restaurant_id => restaurants.id)
#
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

    # Combine date and time in organization's timezone
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
