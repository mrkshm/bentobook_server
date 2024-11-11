class Share < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :shareable, polymorphic: true
  
  enum :status, { pending: 0, accepted: 1, rejected: 2 }
  enum :permission, { view: 0, edit: 1 }
  
  validates :recipient_id, uniqueness: { scope: [:shareable_type, :shareable_id, :creator_id] }
  validate :cannot_share_with_self
  validate :validate_shareable_visibility
  
  private
  
  def cannot_share_with_self
    errors.add(:recipient_id, "can't be the same as creator") if creator_id == recipient_id
  end
  
  def validate_shareable_visibility
    if shareable.is_a?(List) && shareable.personal?
      errors.add(:base, "Cannot share a personal list")
    end
  end
end
