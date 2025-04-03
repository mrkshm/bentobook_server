class Contact < ApplicationRecord
  belongs_to :organization
  belongs_to :user, optional: true  # Keep this for now to track who created the contact
  has_one_attached :avatar
  has_many :visit_contacts
  has_many :visits, through: :visit_contacts

  validates :name, presence: true, uniqueness: { scope: :organization_id }

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

  def self.frequently_used_with(organization, visit, limit: 5)
    available_contacts = organization.contacts.where.not(id: visit.contact_ids)
    total_contacts = available_contacts.count

    if total_contacts <= limit
      available_contacts.order(:name)
    else
      available_contacts
        .joins(:visit_contacts)
        .joins(:visits)
        .group("contacts.id")
        .select("contacts.*, COUNT(visit_contacts.id) as visit_count")
        .order("visit_count DESC, name ASC")
        .limit(limit)
    end
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
