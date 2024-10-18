class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def switch_locale(&action)
    locale = params[:locale] || session[:locale] || I18n.default_locale
    if I18n.available_locales.include?(locale.to_sym)
      session[:locale] = locale
      I18n.with_locale(locale, &action)
    else
      I18n.with_locale(I18n.default_locale, &action)
    end
  end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def extract_locale
    parsed_locale = params[:locale] || session[:locale] || request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end
end
