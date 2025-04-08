module Lists
  class HeaderComponent < ViewComponent::Base
    include HeroiconHelper
    include Rails.application.routes.url_helpers

    def initialize(list:, current_user:)
      @list = list
      @current_user = current_user
      @organization = list.organization
      @is_shared = list.shared?
    end

    private

    attr_reader :list, :current_user, :is_shared, :organization

    def visibility_badge_class
      case list.visibility
      when "personal" then "badge-neutral"
      when "discoverable" then "badge-info"
      end
    end

    def owner_avatar
      return unless is_shared

      # Use organization details instead of organization users
      render(AvatarComponent.new(
        image: organization.logo,
        text: organization.name,
        size: :md,
      ))
    end

    def can_edit?
      list.editable_by?(current_user)
    end
  end
end
