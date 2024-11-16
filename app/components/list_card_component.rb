class ListCardComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  def initialize(list:, current_user:)
    @list = list
    @current_user = current_user
    @statistics = ListStatistics.new(list: list, user: current_user)
    @is_shared = list.owner != current_user
  end

  private

  attr_reader :list, :current_user, :statistics, :is_shared

  def visibility_badge_class
    case list.visibility
    when 'personal' then 'badge-neutral'
    when 'discoverable' then 'badge-info'
    end
  end

  def owner_avatar
    return unless @is_shared

    render(AvatarComponent.new(
      user: list.owner,
      size: :small,
      tooltip: t('.shared_by', user: list.owner.profile.display_name)
    ))
  end
end
