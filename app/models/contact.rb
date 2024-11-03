class Contact < ApplicationRecord
  
  belongs_to :user
  has_one_attached :avatar
  has_many :visit_contacts
  has_many :visits, through: :visit_contacts

  validates :name, presence: true, uniqueness: { scope: :user_id }

  after_commit :process_avatar_variants, if: :avatar_changed?

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

  private

  def avatar_changed?
    saved_changes.key?('avatar_attachment_id') || 
      attachment_changes['avatar'].present?
  end

  def process_avatar_variants
    Rails.logger.info "Processing avatar variants for Contact #{id}"
    generate_image_variants(:avatar)
  end
end
