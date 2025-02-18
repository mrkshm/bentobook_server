# frozen_string_literal: true

module Shell
  class NativeMenuComponent < ViewComponent::Base
    include ApplicationHelper
    include Devise::Controllers::Helpers

    def menu_items
      [
        {
          title: t("nav.restaurants"),
          path: restaurants_path,
          icon: "restaurant"
        },
        {
          title: t("nav.lists"),
          path: lists_path,
          icon: "list",
          notification: notification_dot
        },
        {
          title: t("nav.visits"),
          path: visits_path,
          icon: "calendar"
        },
        {
          title: t("nav.contacts"),
          path: contacts_path,
          icon: "users"
        },
        {
          title: t("nav.profile"),
          path: profile_path,
          icon: "user"
        }
      ]
    end
  end
end
