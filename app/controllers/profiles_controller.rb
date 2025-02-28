class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [ :show, :edit, :update, :change_locale ]

  def show
  end

  def edit
  end

  def update
    if @profile.update(profile_params_without_avatar)
      if params[:profile][:avatar].present?
        ImageHandlingService.process_images(@profile, params, compress: true)
      end
      if params[:profile][:preferred_language].present?
        session[:locale] = @profile.preferred_language
        I18n.locale = @profile.preferred_language
      end
      respond_to do |format|
        format.html { redirect_to profile_path, notice: I18n.t("notices.profile.updated") }
        format.json { render json: { status: :ok } }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = I18n.t("errors.profile.update_failed")
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: { errors: @profile.errors }, status: :unprocessable_entity }
      end
    end
  end

  def change_locale
    locale = params[:locale]
    if I18n.available_locales.map(&:to_s).include?(locale)
      session[:locale] = locale
      I18n.locale = locale
    end
    redirect_to profile_path(locale: nil) # Redirect to profile page without locale in the path
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

  private

  def set_profile
    @profile = current_user.profile
  end

  def profile_params_without_avatar
    params.require(:profile).permit(
      :username, :first_name, :last_name, :about,
     :preferred_language, :preferred_theme
    )
  end
end
