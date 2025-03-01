class ApplicationController < ActionController::Base
  include Pagy::Backend
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

    # Special handling for root paths with locale
    if (request.path == "/fr" || request.path == "/fr/") && I18n.locale == :fr
      return # Don't redirect between /fr and /fr/
    end

    # Normalize paths by removing trailing slashes except for root
    current_path = request.path
    current_path = current_path.chomp("/") unless current_path == "/"

    normalized_path = if I18n.locale == :en
      current_path.gsub(/^\/fr/, "")
    else
      current_path.start_with?("/fr") ? current_path : "/fr#{current_path}"
    end

    # Also normalize the expected path
    normalized_path = normalized_path.chomp("/") unless normalized_path == "/"

    redirect_to normalized_path if current_path != normalized_path
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
