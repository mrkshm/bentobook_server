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
    lang = params[:locale].to_s
    return render :edit, status: :unprocessable_entity unless I18n.available_locales.map(&:to_s).include?(lang)

    session[:locale] = lang
    current_user&.update(language: lang)

    respond_to do |format|
      format.html { redirect_to request.referer.presence || profile_path, status: :see_other }
      format.turbo_stream do
        if hotwire_native_app?
          render "profiles/language/update"
        else
          redirect_to profile_path, status: :see_other
        end
      end
    end
  end

    private

    def set_user
      @user = current_user
    end
  end
end
