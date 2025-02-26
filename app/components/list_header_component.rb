class ListHeaderComponent < ViewComponent::Base
  include HeroiconHelper
  include Rails.application.routes.url_helpers

  def initialize(list:, current_user:)
    @list = list
    @current_user = current_user
    @is_shared = list.owner != current_user
  end

  private

  attr_reader :list, :current_user, :is_shared

  def visibility_badge_class
    case list.visibility
    when "personal" then "badge-neutral"
    when "discoverable" then "badge-info"
    end
  end

  def owner_avatar
    return unless @is_shared

    render(AvatarComponent.new(
      image: list.owner.avatar,
      text: list.owner.name,
      size: :md,
    ))
  end

  def can_edit?
    list.editable_by?(current_user)
  end
end
