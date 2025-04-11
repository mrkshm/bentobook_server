module Lists
  class SharedActionsComponent < ViewComponent::Base
    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers
    include HeroiconHelper

    def initialize(list:, current_user:)
      @list = list
      @current_user = current_user
      @organization = list.organization
      @permissions = {
        can_edit: list.editable_by?(current_user),
        is_owner_org: user_in_owner_org?
      }
      @owner = list.owner
    end

    private

    attr_reader :list, :current_user, :organization, :permissions, :owner

    def user_in_owner_org?
      current_user.organizations.exists?(id: organization.id)
    end

    def any_restaurants_to_import?
      list.restaurants.exists?(
        [ "NOT EXISTS (?)",
          Current.organization.restaurants.where(
            "restaurants.id = list_restaurants.restaurant_id"
          )
        ]
      )
    end
  end
end
