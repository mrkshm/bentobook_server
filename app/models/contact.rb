class Contact < ApplicationRecord
  belongs_to :user
  has_one_attached :avatar
  has_many :visit_contacts
  has_many :visits, through: :visit_contacts

  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :search, ->(query) {
    return all unless query.present?
    
    where(
      "name ILIKE :query OR 
       email ILIKE :query OR 
       city ILIKE :query OR 
       country ILIKE :query OR 
       notes ILIKE :query",
      query: "%#{sanitize_sql_like(query)}%"
    )
  }

  def visits_count
    visits.count
  end
end
