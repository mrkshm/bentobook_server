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

    # Check if current user is a member of the list's organization
    def current_user_in_org?
      current_user.organizations.exists?(id: organization.id)
    end

    def owner_avatar
      return unless is_shared

      # Use organization name as text for avatar
      render(AvatarComponent.new(
        text: organization.name,
        size: :md,
        placeholder_type: :initials
      ))
    end

    def can_edit?
      list.editable_by?(current_user)
    end
  end
end
