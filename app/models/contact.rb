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

  def self.frequently_used_with(user, visit, limit: 5)
    joins(:visit_contacts)
      .joins(:visits)
      .where(visits: { user_id: user.id })
      .where.not(id: visit.contact_ids)
      .group("contacts.id")
      .select("contacts.*, COUNT(visit_contacts.id) as visit_count")
      .order("visit_count DESC")
      .limit(limit)
  end

  def visits_count
    visits.count
  end

  private

  def avatar_changed?
    saved_changes.key?("avatar_attachment_id") ||
      attachment_changes["avatar"].present?
  end
end
