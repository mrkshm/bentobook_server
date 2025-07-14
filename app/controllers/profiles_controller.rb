class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_and_organization, only: [ :show, :edit, :update, :delete_avatar, :update_theme ]

  def show
    Rails.logger.debug "User language: #{@user.language.inspect}"
    Rails.logger.debug "Before render - I18n.locale: #{I18n.locale.inspect}"
  end

  def edit
  end

  def update
    result = PreprocessAvatarService.call(params.dig(:organization, :avatar)) if params.dig(:organization, :avatar).present?

    if params.dig(:organization, :avatar).present? && !result[:success]
      flash.now[:alert] = result[:error]
      return render :edit, status: :unprocessable_entity
    end

    # Store the current language before update
    old_language = @user.language

    # Update user attributes
    user_updated = if params[:user].present?
      @user.update(user_params)
    else
      true
    end

    # Update organization attributes
    org_updated = if params[:organization].present?
      @organization.update(organization_params)
    else
      true
    end

    if user_updated && org_updated
      # Handle avatar update if present
      if result&.dig(:success)
        # Remove old avatars if they exist
        @organization.avatar_medium.purge if @organization.avatar_medium.attached?
        @organization.avatar_thumbnail.purge if @organization.avatar_thumbnail.attached?

        # Attach new variants
        @organization.avatar_medium.attach(
          io: result[:variants][:medium][:io],
          filename: result[:variants][:medium][:filename],
          content_type: result[:variants][:medium][:content_type]
        )
        @organization.avatar_thumbnail.attach(
          io: result[:variants][:thumbnail][:io],
          filename: result[:variants][:thumbnail][:filename],
          content_type: result[:variants][:thumbnail][:content_type]
        )
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
           formats: [ :html ],
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

  def delete_avatar
    if @organization.avatar_medium.attached? || @organization.avatar_thumbnail.attached?
      @organization.avatar_medium.purge if @organization.avatar_medium.attached?
      @organization.avatar_thumbnail.purge if @organization.avatar_thumbnail.attached?
      @organization.save!
    end
    redirect_to edit_profile_path(locale: current_locale), notice: t(".avatar_removed")
  end

  private

  def set_user_and_organization
    @user = current_user
    @organization = current_user.organizations.first
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :language,
      :theme
    )
  end

  def organization_params
    params.require(:organization).permit(
      :username,
      :name,
      :about
    )
  end
end
