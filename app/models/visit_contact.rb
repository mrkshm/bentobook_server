class VisitContact < ApplicationRecord
  belongs_to :visit
  belongs_to :contact

  validates :visit_id, uniqueness: { scope: :contact_id }
  validate :contact_belongs_to_visit_organization

  private

  def contact_belongs_to_visit_organization
    return unless visit && contact

    unless contact.organization_id == visit.organization_id
      errors.add(:contact, :invalid)
    end
  end
end
