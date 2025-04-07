class Organization < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
  has_many :restaurants
  has_many :images, as: :imageable, dependent: :destroy
  has_many :lists, dependent: :destroy

  # Shares where this organization is the source (owner sharing with others)
  has_many :outgoing_shares, class_name: "Share", foreign_key: "source_organization_id", dependent: :destroy

  # Shares where this organization is the target (receiving shared items)
  has_many :incoming_shares, class_name: "Share", foreign_key: "target_organization_id", dependent: :destroy

  # Lists shared with this organization
  has_many :shared_lists, through: :incoming_shares, source: :shareable, source_type: "List"

  has_many :contacts, dependent: :destroy
  has_many :visits, dependent: :destroy

  def share_list(list, target_organization, options = {})
    raise ArgumentError, "List doesn't belong to this organization" unless lists.include?(list)

    outgoing_shares.create!({
      shareable: list,
      target_organization: target_organization,
      creator: options[:creator],
      permission: options[:permission] || :view,
      reshareable: options[:reshareable] || false,
      status: :pending
    })
  end

  def shared_lists_with(organization)
    List.joins(:shares)
        .where(shares: {
          source_organization_id: self.id,
          target_organization_id: organization.id,
          status: :accepted
        })
  end

  def pending_shared_lists_with(organization)
    List.joins(:shares)
        .where(shares: {
          source_organization_id: self.id,
          target_organization_id: organization.id,
          status: :pending
        })
  end

  def accept_share(share)
    raise ArgumentError, "Share doesn't belong to this organization" unless share.target_organization_id == self.id
    share.update!(status: :accepted)
  end

  def reject_share(share)
    raise ArgumentError, "Share doesn't belong to this organization" unless share.target_organization_id == self.id
    share.update!(status: :rejected)
  end
end
