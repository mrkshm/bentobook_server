class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :set_locale
  before_action :ensure_locale_matches_url
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
    locale = if user_signed_in?
      params[:locale] || session[:locale] || I18n.default_locale
    else
      params[:locale] || I18n.default_locale
    end

    locale = locale.to_s if locale

    if locale && I18n.available_locales.include?(locale.to_sym)
      session[:locale] = locale if user_signed_in?  # Only store in session if authenticated
      I18n.locale = locale
    else
      I18n.locale = I18n.default_locale
    end
  end

  def ensure_locale_matches_url
    return if request.path.start_with?("/api") # Skip for API routes

    current_path = request.path
    expected_path = if I18n.locale == :en
      current_path.gsub(/^\/fr/, "")
    else
      current_path.start_with?("/fr") ? current_path : "/fr#{current_path}"
    end

    redirect_to expected_path if current_path != expected_path
  end

  def after_sign_in_path_for(resource)
    if turbo_native_app?
      home_dashboard_path
    else
      restaurants_path
    end
  end

  def default_url_options
    return {} if I18n.locale == :en
    { locale: I18n.locale }
  end

  def extract_locale
    parsed_locale = params[:locale] || session[:locale] || request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end
end
