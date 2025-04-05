class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :show, :edit, :update, :change_locale, :delete_avatar ]  # Added delete_avatar

  def show
    Rails.logger.debug "Profile preferred_language: #{@profile.preferred_language.inspect}, class: #{@profile.preferred_language.class}"
    Rails.logger.debug "Before render - Profile preferred_language: #{@profile.preferred_language.inspect}"
    Rails.logger.debug "Before render - I18n.locale: #{I18n.locale.inspect}"
  end

  def edit
  end

  def update
    result = PreprocessAvatarService.call(params[:profile][:avatar]) if params[:profile][:avatar].present?

    if params[:profile][:avatar].present? && !result[:success]
      flash.now[:alert] = t(".image_processing_error")
      return render :edit, status: :unprocessable_entity
    end

    # Store the current preferred language before update
    old_language = @profile.preferred_language

    if @profile.update(profile_params_without_avatar)
      # Handle avatar update if present
      if result&.dig(:success)
        # Remove old avatars if they exist
        @profile.avatar_medium.purge if @profile.avatar_medium.attached?
        @profile.avatar_thumbnail.purge if @profile.avatar_thumbnail.attached?

        # Attach new variants
        @profile.avatar_medium.attach(result[:variants][:medium])
        @profile.avatar_thumbnail.attach(result[:variants][:thumbnail])
      end

      # Update session locale if preferred_language changed
      new_language = @profile.preferred_language
      if new_language.present? && new_language != old_language
        session[:locale] = new_language
        I18n.locale = new_language

        if hotwire_native_app?
          # Clear navigation stack and redirect to dashboard
          render turbo_stream: turbo_stream.append("body") do
            tag.script(%(
              window.localStorage.clear();
              window.Turbo.clearCache();
              window.Turbo.visit('#{home_dashboard_path(locale: current_locale)}', { action: 'replace' });
            )).html_safe
          end
        else
          redirect_to profile_path(locale: current_locale), notice: t(".updated")
        end
      else
        redirect_to profile_path(locale: current_locale), notice: t(".updated")
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def change_locale
    locale = params[:locale].to_s

    if I18n.available_locales.map(&:to_s).include?(locale)
      session[:locale] = locale
      @profile&.update(preferred_language: locale)

      # Simple redirect based on platform
      redirect_to(hotwire_native_app? ? home_dashboard_path(locale: locale) : profile_path(locale: locale))
    else
      redirect_to profile_path(locale: current_locale), alert: t(".invalid_locale")
    end
  end

  def search
    return head(:bad_request) unless request.xhr?

    # First get the user's contacts that have profiles
    @profiles = Profile.joins(:user)
                      .where.not(users: { id: current_user.id })
                      .where("profiles.username ILIKE :query OR
                             profiles.first_name ILIKE :query OR
                             profiles.last_name ILIKE :query OR
                             users.email ILIKE :query",
                             query: "%#{params[:query]}%")
                      .limit(5)

    Rails.logger.info "Found #{@profiles.count} matching contacts with profiles"

    render partial: "profiles/search_results",
           formats: [ :html ],
           layout: false,
           status: :ok
  end

  def update_theme
    new_theme = params[:theme].to_s.strip

    if Profile::VALID_THEMES.include?(new_theme)
      if @profile.update(preferred_theme: new_theme)
        render json: { status: "success", theme: new_theme }
      else
        render json: { status: "error" }, status: :unprocessable_entity
      end
    else
      render json: { status: "error", message: "Invalid theme" }, status: :unprocessable_entity
    end
  end

  def edit_language
    @available_locales = I18n.available_locales.map do |locale|
      { code: locale.to_s, name: I18n.t("locales.#{locale}") }
    end
    @current_locale = (current_user&.profile&.preferred_language || I18n.locale).to_s
  end

  def delete_avatar
    @profile.avatar_medium.purge if @profile.avatar_medium.attached?
    @profile.avatar_thumbnail.purge if @profile.avatar_thumbnail.attached?
    redirect_to edit_profile_path(locale: current_locale), notice: t(".avatar_removed")
  end

  def set_profile
    @profile = current_user.profile
  end

  def profile_params_without_avatar
    params.require(:profile).permit(
      :username,
      :first_name,
      :last_name,
      :about,
      :preferred_language,
      :preferred_theme
    )
  end

  private

  # Removed locale_changed? method
end
