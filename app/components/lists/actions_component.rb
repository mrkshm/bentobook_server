module Lists
  class ActionsComponent < ViewComponent::Base
    include HeroiconHelper
    include Rails.application.routes.url_helpers

    def initialize(list:, current_user:)
      @list = list
      @current_user = current_user
      @permissions = {
        can_edit: list.editable_by?(current_user),
        is_owner: list.owner == current_user,
        can_share: can_share?,
        can_export: true # Everyone can export for now
      }
    end

    private

    attr_reader :list, :current_user, :permissions

    def can_share?
      return true if list.owner == current_user
      # Add logic for resharing permission when implemented
      # share = list.shares.find_by(recipient: current_user)
      # share&.can_reshare?
      false
    end
  end
end
