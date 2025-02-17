# frozen_string_literal: true

class LanguageSwitcherComponent < ViewComponent::Base
  include Devise::Controllers::Helpers

  def initialize(current_locale: I18n.locale)
    @current_locale = current_locale
  end

  def current_locale
    @current_locale.to_sym
  end

  def other_locale
    current_locale == :en ? :fr : :en
  end

  def other_locale_name
    other_locale == :en ? "English" : "Français"
  end
end
