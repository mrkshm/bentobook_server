# frozen_string_literal: true

class LanguageSwitcherComponent < ApplicationComponent
  include Devise::Controllers::Helpers

  def initialize(current_locale:)
    @current_locale = current_locale.to_s
  end

  def current_locale_name
    name = I18n.t("locales.#{@current_locale}")
    name
  end

  def available_locales
    locales = I18n.available_locales.map do |locale|
      { code: locale.to_s, name: I18n.t("locales.#{locale}") }
    end
    locales
  end

  def opposite_locale
    @current_locale == "en" ? "fr" : "en"
  end
end
