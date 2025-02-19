# frozen_string_literal: true

module Shell
  class NativeMenuComponent < ViewComponent::Base
    include ApplicationHelper
    include HeroiconHelper
    include Devise::Controllers::Helpers

    def menu_items
      [
        {
          title: t("nav.restaurants"),
          path: restaurants_path
        },
        # {
        #   title: t("nav.lists"),
        #   path: lists_path
        # },
        {
          title: t("nav.visits"),
          path: visits_path
        },
        {
          title: t("nav.contacts"),
          path: contacts_path
          # },
          # {
          #   title: t("nav.profile"),
          #   path: profile_path
        }
      ]
    end
  end
end
