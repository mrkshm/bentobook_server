class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale
  before_action :configure_turbo_native_auth

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def configure_turbo_native_auth
    if turbo_native_app?
      request.variant = :native
    end
  end

  def turbo_native_app?
    request.user_agent&.include?("Turbo Native")
  end

  def set_locale
    Rails.logger.info "LOCALE DEBUG: params[:locale]=#{params[:locale].inspect}"
    Rails.logger.info "LOCALE DEBUG: session[:locale]=#{session[:locale].inspect}"
    Rails.logger.info "LOCALE DEBUG: I18n.default_locale=#{I18n.default_locale.inspect}"
    Rails.logger.info "LOCALE DEBUG: request.env['HTTP_ACCEPT_LANGUAGE']=#{request.env['HTTP_ACCEPT_LANGUAGE'].inspect}"

    locale = params[:locale] || session[:locale] || I18n.default_locale
    locale = locale.to_s if locale
    Rails.logger.info "LOCALE DEBUG: computed locale=#{locale.inspect}"

    if locale && I18n.available_locales.include?(locale.to_sym)
      session[:locale] = locale
      I18n.locale = locale
      Rails.logger.info "LOCALE DEBUG: final I18n.locale=#{I18n.locale.inspect}"
    else
      I18n.locale = I18n.default_locale
      Rails.logger.info "LOCALE DEBUG: fallback I18n.locale=#{I18n.locale.inspect}"
    end
  end

  def default_url_options
    return {} if I18n.locale == :en
    { locale: I18n.locale }
  end

  def after_sign_in_path_for(resource)
    if turbo_native_app?
      restaurants_path
    else
      stored_location_for(resource) || root_path
    end
  end

  def extract_locale
    parsed_locale = params[:locale] || session[:locale] || request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end
end
