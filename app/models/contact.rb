# == Schema Information
#
# Table name: contacts
#
#  id              :bigint           not null, primary key
#  city            :string
#  country         :string
#  email           :string
#  name            :string
#  notes           :text
#  phone           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_contacts_on_name_and_organization_id  (name,organization_id) UNIQUE
#  index_contacts_on_organization_id           (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class Contact < ApplicationRecord
  belongs_to :organization
  has_one_attached :avatar  # Temporary for migration
  has_one_attached :avatar_medium
  has_one_attached :avatar_thumbnail
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
        .left_joins(:visit_contacts)
        .group("contacts.id")
        .select("contacts.*, COUNT(visit_contacts.id) as visit_count")
        .order("visit_count DESC, name ASC")
        .limit(limit)
    end
  end

  def visits_count
    visits.count
  end

  def avatar_medium_url
    generate_url(avatar_medium)
  end

  def avatar_thumbnail_url
    generate_url(avatar_thumbnail)
  end

  private

  def avatar_changed?
    saved_changes.key?("avatar_medium_attachment_id") ||
      saved_changes.key?("avatar_thumbnail_attachment_id") ||
      attachment_changes["avatar_medium"].present? ||
      attachment_changes["avatar_thumbnail"].present?
  end

  def generate_url(attachment)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  end
end
