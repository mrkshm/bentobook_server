# == Schema Information
#
# Table name: shares
#
#  id                     :bigint           not null, primary key
#  permission             :integer          default("view")
#  reshareable            :boolean          default(TRUE), not null
#  shareable_type         :string           not null
#  status                 :integer          default("pending")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  creator_id             :bigint           not null
#  shareable_id           :bigint           not null
#  source_organization_id :bigint           not null
#  target_organization_id :bigint           not null
#
# Indexes
#
#  index_shares_on_creator_id                   (creator_id)
#  index_shares_on_organizations_and_shareable  (source_organization_id,target_organization_id,shareable_type,shareable_id)
#  index_shares_on_shareable                    (shareable_type,shareable_id)
#  index_shares_on_source_organization_id       (source_organization_id)
#  index_shares_on_target_organization_id       (target_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (source_organization_id => organizations.id)
#  fk_rails_...  (target_organization_id => organizations.id)
#
class Share < ApplicationRecord
  # Organization-based sharing model
  # Allows sharing items between organizations

  # The organization that owns the shared item
  belongs_to :source_organization, class_name: "Organization"

  # The organization receiving access to the shared item
  belongs_to :target_organization, class_name: "Organization"

  # The user who initiated the share (for audit/tracking)
  belongs_to :creator, class_name: "User"

  # The item being shared (e.g., a list)
  belongs_to :shareable, polymorphic: true

  enum :status, { pending: 0, accepted: 1, rejected: 2 }
  enum :permission, { view: 0, edit: 1 }

  validates :target_organization_id, uniqueness: {
    scope: [ :shareable_type, :shareable_id, :source_organization_id ]
  }
  validate :cannot_share_with_self
  validate :validate_status_transition, if: :status_changed?
  validates :reshareable, inclusion: { in: [ true, false ] }

  scope :accepted, -> { where(status: :accepted) }
  scope :pending, -> { where(status: :pending) }
  scope :rejected, -> { where(status: :rejected) }

  # Find shares where the given organization is the target
  scope :shared_with, ->(organization) { where(target_organization: organization) }

  # Find shares where the given organization is the source
  scope :shared_by, ->(organization) { where(source_organization: organization) }

  private

  def cannot_share_with_self
    if source_organization_id == target_organization_id
      errors.add(:target_organization_id, "can't be the same as source organization")
    end
  end

  def can_be_reshared?
    reshareable? && accepted?
  end

  def validate_status_transition
    if status_was == "accepted" && status == "pending"
      errors.add(:status, "cannot transition back to pending once accepted")
      raise StandardError, "Cannot transition from accepted to pending"
    end
  end
end
