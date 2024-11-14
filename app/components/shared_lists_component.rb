class SharedListsComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
    @pending_shares = user.shares.pending.includes(:shareable, creator: :profile)
    @accepted_shares = user.shares.accepted.includes(:shareable, creator: :profile)
  end

  def render?
    @pending_shares.exists? || @accepted_shares.exists?
  end
end
