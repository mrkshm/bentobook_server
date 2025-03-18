class VisitContact < ApplicationRecord
  belongs_to :visit
  belongs_to :contact

  validates :visit_id, uniqueness: { scope: :contact_id }
  validate :contact_belongs_to_visit_user

  private

  def contact_belongs_to_visit_user
    return unless visit && contact

    unless contact.user_id == visit.user_id
      errors.add(:contact, :invalid)
    end
  end
end
