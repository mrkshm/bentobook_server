class ShareeAvatarsComponent < ViewComponent::Base
  def initialize(list:)
    @list = list
    @shares = list.shares.includes(recipient: { profile: { avatar_attachment: :blob } })
  end

  private

  attr_reader :list, :shares

  def render?
    shares.any?
  end

  def tooltip_for(share)
    user_name = share.recipient.profile.display_name
    case share.status
    when "pending"
      t(".pending_tooltip", user: user_name)
    when "accepted"
      t(".accepted_tooltip", user: user_name)
    end
  end
end
