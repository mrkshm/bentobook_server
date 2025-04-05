class Organization < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
  has_many :restaurants
  has_many :images, as: :imageable, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :shares, through: :lists
  has_many :contacts, dependent: :destroy
  has_many :visits, dependent: :destroy

  def share_list(list, recipient, options = {})
    raise ArgumentError, "List doesn't belong to this organization" unless lists.include?(list)

    list.shares.create!({
      recipient: recipient,
      creator: options[:creator],
      permission: options[:permission] || :view,
      reshareable: options[:reshareable] || false,
      status: :pending
    })
  end

  def shared_lists_with(user)
    lists.joins(:shares).where(shares: { recipient: user, status: :accepted })
  end

  def pending_shared_lists_with(user)
    lists.joins(:shares).where(shares: { recipient: user, status: :pending })
  end

  def accept_share(share)
    raise ArgumentError, "Share doesn't belong to this organization" unless shares.include?(share)
    share.update!(status: :accepted)
  end

  def reject_share(share)
    raise ArgumentError, "Share doesn't belong to this organization" unless shares.include?(share)
    share.update!(status: :rejected)
  end
end
