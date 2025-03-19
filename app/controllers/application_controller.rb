class ApplicationController < ActionController::Base
  include Pagy::Backend
  include LocaleHelper
  before_action :set_locale
  before_action :ensure_locale_matches_url, unless: :skip_locale_check?
  before_action :configure_turbo_native_auth
  before_action :debug_request

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
    I18n.locale = if params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
      params[:locale]
    elsif user_signed_in? && current_user.profile&.preferred_language.present?
      current_user.profile.preferred_language
    else
      I18n.default_locale
    end
  end

  def ensure_locale_matches_url
    return if request.path.start_with?("/api") # Skip for API routes

    # Get the current locale from the URL
    url_locale = request.path.start_with?("/fr") ? :fr : :en

    # If URL matches the current locale, no redirect needed
    return if (I18n.locale == :fr && url_locale == :fr) ||
              (I18n.locale == :en && url_locale == :en)

    # Normalize paths
    current_path = request.path.chomp("/")
    current_path = "/" if current_path.empty?

    # Build the correct path based on locale
    new_path = if I18n.locale == :en
      current_path.gsub(/^\/fr/, "")
    else
      current_path.start_with?("/fr") ? current_path : "/fr#{current_path}"
    end

    # Only redirect if paths are different
    redirect_to(new_path) if new_path != current_path
  end

  def after_sign_in_path_for(resource)
    if turbo_native_app?
      home_dashboard_path
    else
      restaurants_path
    end
  end

  def default_url_options
    return {} if I18n.locale == I18n.default_locale
    { locale: I18n.locale }
  end

  def extract_locale
    parsed_locale = params[:locale] || session[:locale] || request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}/)&.first
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def debug_request
    puts "====== DEBUG ======"
    puts "Request path: #{request.path}"
    puts "Request method: #{request.method}"
    puts "Session: #{session}"
    puts "Params: #{params}"
    puts "=================="
  end

  def skip_locale_check?
    # Skip locale check for locale changing actions and API routes
    controller_name == "profiles" && action_name == "change_locale" ||
    request.path.start_with?("/api")
  end
end
