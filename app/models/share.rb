class Share < ApplicationRecord
  # TODO: Future sharing enhancements to consider:
  # - Sharing via email/link (recipient might not be a user)
  # - Premium list access
  # - Business/influencer use cases with public/premium lists
  # For now, keeping the implementation focused on direct user-to-user sharing

  belongs_to :creator, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :shareable, polymorphic: true
  
  enum :status, { pending: 0, accepted: 1, rejected: 2 }
  enum :permission, { view: 0, edit: 1 }
  
  validates :recipient_id, uniqueness: { scope: [:shareable_type, :shareable_id, :creator_id] }
  validate :cannot_share_with_self
  validate :validate_status_transition, if: :status_changed?
  
  private
  
  def cannot_share_with_self
    errors.add(:recipient_id, "can't be the same as creator") if creator_id == recipient_id
  end
  
  def validate_status_transition
    if status_was == 'accepted' && status == 'pending'
      errors.add(:status, "cannot transition back to pending once accepted")
      raise StandardError, "Cannot transition from accepted to pending"
    end
  end
end
