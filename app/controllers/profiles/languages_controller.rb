module Profiles
  class LanguagesController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :authenticate_user!
    before_action :set_user

    def edit
      @available_locales = I18n.available_locales.map do |locale|
        { code: locale.to_s, name: I18n.t("locales.#{locale}") }
      end
      @current_locale = (@user.language || I18n.locale).to_s

      render template: "profiles/language/edit"
    end

    def update
      language = params[:language].to_s

      if I18n.available_locales.map(&:to_s).include?(language)
        if @user.update(language: language)
          # Update the session
          session[:locale] = language
          I18n.locale = language

          # Simple redirect to profile with the new locale
          # This works because the form has data-turbo-frame="_top"
          redirect_to profile_path(locale: language)
        else
          render template: "profiles/language/edit",
                status: :unprocessable_entity
        end
      else
        flash[:alert] = t("profiles.invalid_locale")
        render template: "profiles/language/edit",
              status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = current_user
    end
  end
end
