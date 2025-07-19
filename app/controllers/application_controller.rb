class ApplicationController < ActionController::Base
  include Pagy::Backend
  include LocaleHelper

  before_action :set_locale
  before_action :configure_turbo_native_auth
  before_action :set_current_attributes

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_current_attributes
    Current.user = current_user
    Current.organization ||= current_user&.organizations&.first
  end

  def configure_turbo_native_auth
    if turbo_native_app?
      request.variant = :native
    end
  end

  def turbo_native_app?
    request.user_agent&.include?("Turbo Native")
  end

  def set_locale
    I18n.locale = session[:locale] || current_user&.language || I18n.default_locale
  end

  def after_sign_in_path_for(resource)
    if turbo_native_app?
      home_dashboard_path
    else
      restaurants_path
    end
  end

  def default_url_options
    if user_signed_in? || I18n.locale == I18n.default_locale
      {}
    else
      { locale: I18n.locale }
    end
  end
end
