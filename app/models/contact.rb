class Contact < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar
  has_many :visit_contacts
  has_many :visits, through: :visit_contacts

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def visits_count
    visits.count
  end
end
