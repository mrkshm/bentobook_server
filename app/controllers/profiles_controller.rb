class ProfilesController < ApplicationController
    before_action :authenticate_user!, except: :change_locale
    before_action :set_profile, except: :change_locale
  
    def show
      Rails.logger.debug "ProfilesController#show, current locale: #{I18n.locale}"
    end
  
    def edit
    end
  
    def update
      if @profile.update(profile_params)
        redirect_to profile_path, notice: I18n.t('notices.profile.updated')
      else
        flash.now[:alert] = I18n.t('errors.profile.update_failed')
        render :edit, status: :unprocessable_entity
      end
    end
  
    def change_locale
      new_locale = params[:locale].to_s.strip
      if I18n.available_locales.map(&:to_s).include?(new_locale)
        session[:locale] = new_locale
        I18n.locale = new_locale
        redirect_to profile_path, notice: I18n.t('notices.locale.changed', locale: new_locale)
      else
        redirect_to profile_path, alert: I18n.t('errors.locale.invalid')
      end
    end
  
    private
  
    def set_profile
      @profile = current_user.profile || current_user.create_profile!
    end
  
    def profile_params
      params.require(:profile).permit(:username, :first_name, :last_name, :about, :avatar)
    end
  end
