class SharedListActionsComponent < ViewComponent::Base
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  def initialize(list:, current_user:)
    @list = list
    @current_user = current_user
    @can_edit = list.editable_by?(current_user)
    @owner = list.owner
  end

  private

  attr_reader :list, :current_user, :can_edit, :owner

  def any_restaurants_to_import?
    list.restaurants.exists?(
      ['NOT EXISTS (?)', 
        Current.organization.restaurants.where(
          'restaurants.id = list_restaurants.restaurant_id'
        )
      ]
    )
  end
end
