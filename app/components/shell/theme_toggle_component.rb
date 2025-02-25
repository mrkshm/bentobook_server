# frozen_string_literal: true

module Shell
  class ThemeToggleComponent < ViewComponent::Base
    include Rails.application.routes.url_helpers

    def initialize(current_theme: nil)
      @current_theme = current_theme
    end

    def component_data
      {
        controller: "theme-toggle",
        "theme-toggle-current-theme-value": @current_theme || "light",
        "theme-toggle-theme-path-value": update_theme_profile_path(locale: nil),
        action: "click->theme-toggle#toggle"
      }
    end
  end
end
