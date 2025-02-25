# frozen_string_literal: true

class LanguageSwitcherComponent < ViewComponent::Base
  include Devise::Controllers::Helpers

  def initialize(current_locale:)
    @current_locale = current_locale
  end

  def current_locale_name
    I18n.t("locales.#{@current_locale}")
  end

  def available_locales
    I18n.available_locales.map do |locale|
      { code: locale.to_s, name: I18n.t("locales.#{locale}") }
    end
  end
end
