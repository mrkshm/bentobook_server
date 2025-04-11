class ShareeAvatarsComponent < ViewComponent::Base
  include HeroiconHelper

  def initialize(list:)
    @list = list
    # Update to use the correct associations for avatar loading
    # Organizations have avatar_medium and avatar_thumbnail, not avatar_attachment
    @shares = list.shares.includes(:target_organization)
  end

  private

  attr_reader :list, :shares

  def render?
    shares.any?
  end

  def tooltip_for(share)
    # Get name from target organization
    org_name = share.target_organization&.name.presence || "Unknown Organization"

    case share.status
    when "pending"
      t(".pending_tooltip", user: org_name)
    when "accepted"
      t(".accepted_tooltip", user: org_name)
    end
  end
end
