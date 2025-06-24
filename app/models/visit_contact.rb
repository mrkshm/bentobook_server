# == Schema Information
#
# Table name: visit_contacts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  contact_id :bigint           not null
#  visit_id   :bigint           not null
#
# Indexes
#
#  index_visit_contacts_on_contact_id  (contact_id)
#  index_visit_contacts_on_visit_id    (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (visit_id => visits.id)
#
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
