# frozen_string_literal: true

class LanguageSwitcherComponent < ViewComponent::Base
  include Devise::Controllers::Helpers

  def initialize(current_locale: I18n.locale)
    @current_locale = current_locale
  end

  def current_locale
    @current_locale.to_sym
  end

  def current_locale_name
    current_locale == :en ? "English" : "Français"
  end

  def available_locales
    [
      { code: :en, name: "English" },
      { code: :fr, name: "Français" }
    ]
  end
end
