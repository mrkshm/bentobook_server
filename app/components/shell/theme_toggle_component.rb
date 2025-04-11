# frozen_string_literal: true

module Shell
  class ThemeToggleComponent < ApplicationComponent
    include Rails.application.routes.url_helpers
    include Devise::Controllers::Helpers

    def initialize
      # No parameters - component is self-contained
    end

    def component_data
      data = {
        controller: "theme-toggle",
        "theme-toggle-current-theme-value": current_user_theme,
        action: "click->theme-toggle#toggle"
      }

      # Only add server sync path for authenticated users
      if user_signed_in?
        data["theme-toggle-theme-path-value"] = update_theme_profile_path(locale: current_locale)
      end

      data
    end

    private

    def current_user_theme
      return nil unless user_signed_in?
      current_user.theme || "light"
    end
  end
end
