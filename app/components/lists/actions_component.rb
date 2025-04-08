module Lists
  class ActionsComponent < ViewComponent::Base
    include HeroiconHelper
    include Rails.application.routes.url_helpers

    def initialize(list:, current_user:)
      @list = list
      @current_user = current_user
      @organization = list.organization
      @permissions = {
        can_edit: list.editable_by?(current_user),
        is_owner_org: user_in_owner_org?,
        can_share: can_share?,
        can_export: true # Everyone can export for now
      }
    end

    private

    attr_reader :list, :current_user, :organization, :permissions

    def user_in_owner_org?
      current_user.organizations.exists?(id: organization.id)
    end

    def can_share?
      # User can share if they belong to the list's organization
      return true if user_in_owner_org?

      # Add logic for resharing permission when implemented
      # share = list.shares.find_by(target_organization_id: current_user.organizations.pluck(:id))
      # share&.can_reshare?
      false
    end
  end
end
