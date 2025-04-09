class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:show, :edit, :update, :change_locale, :delete_avatar]

  def show
    Rails.logger.debug "User language: #{@user.language.inspect}"
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

    # Store the current language before update
    old_language = @user.language

    # Update user attributes
    user_updated = @user.update(user_params)
    # Update organization attributes
    org_updated = @organization.update(organization_params)

    if user_updated && org_updated
      # Handle avatar update if present
      if result&.dig(:success)
        # Remove old avatars if they exist
        @organization.avatar_medium.purge if @organization.avatar_medium.attached?
        @organization.avatar_thumbnail.purge if @organization.avatar_thumbnail.attached?

        # Attach new variants
        @organization.avatar_medium.attach(result[:variants][:medium])
        @organization.avatar_thumbnail.attach(result[:variants][:thumbnail])
      end

      # Update session locale if language changed
      new_language = @user.language
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
      @user.update(language: locale)

      # Simple redirect based on platform
      redirect_to(hotwire_native_app? ? home_dashboard_path(locale: locale) : profile_path(locale: locale))
    else
      redirect_to profile_path(locale: current_locale), alert: t(".invalid_locale")
    end
  end

  def search
    return head(:bad_request) unless request.xhr?

    @organizations = Organization.joins(memberships: :user)
                               .where.not(users: { id: current_user.id })
                               .where("organizations.username ILIKE :query OR
                                     organizations.name ILIKE :query OR
                                     users.first_name ILIKE :query OR
                                     users.last_name ILIKE :query OR
                                     users.email ILIKE :query",
                                     query: "%#{params[:query]}%")
                               .limit(5)

    Rails.logger.info "Found #{@organizations.count} matching organizations"

    render partial: "profiles/search_results",
           formats: [:html],
           layout: false,
           status: :ok
  end

  def update_theme
    new_theme = params[:theme].to_s.strip

    if %w[light dark].include?(new_theme)
      if @user.update(theme: new_theme)
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
    @current_locale = (@user.language || I18n.locale).to_s
  end

  def delete_avatar
    @organization.avatar_medium.purge if @organization.avatar_medium.attached?
    @organization.avatar_thumbnail.purge if @organization.avatar_thumbnail.attached?
    redirect_to edit_profile_path(locale: current_locale), notice: t(".avatar_removed")
  end

  private

  def set_profile
    @user = current_user
    @organization = current_user.organizations.first
  end

  def user_params
    params.require(:profile).permit(
      :first_name,
      :last_name,
      :language,
      :theme
    )
  end

  def organization_params
    params.require(:profile).permit(
      :username,
      :name,
      :about
    )
  end
end
