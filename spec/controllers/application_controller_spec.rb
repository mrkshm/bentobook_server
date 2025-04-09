require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
      super
    end

    def set_locale
      super
    end
  end

  describe "#after_sign_in_path_for" do
    let(:user) { create(:user) }

    context "when in a native app" do
      it "returns the home dashboard path" do
        allow(controller).to receive(:turbo_native_app?).and_return(true)
        expect(controller.after_sign_in_path_for(user)).to eq(home_dashboard_path(locale: nil))
      end
    end

    context "when in a web app" do
      it "returns the restaurants path" do
        allow(controller).to receive(:turbo_native_app?).and_return(false)
        expect(controller.after_sign_in_path_for(user)).to eq(restaurants_path(locale: nil))
      end
    end
  end

  describe "#set_locale" do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it "sets locale from params if present" do
      allow(controller).to receive(:params).and_return({ locale: 'fr' })
      controller.send(:set_locale)
      expect(I18n.locale).to eq(:fr)
    end

    it "sets locale from user language if params not present" do
      user.language = 'fr'
      allow(controller).to receive(:params).and_return({})
      controller.send(:set_locale)
      expect(I18n.locale).to eq(:fr)
    end

    it "falls back to default locale if neither params nor user language present" do
      user.language = nil
      allow(controller).to receive(:params).and_return({})
      controller.send(:set_locale)
      expect(I18n.locale).to eq(I18n.default_locale)
    end
  end

  describe "#skip_locale_check?" do
    it "skips check for any controller with change_locale action" do
      # Test with users controller
      allow(controller).to receive(:controller_name).and_return("users")
      allow(controller).to receive(:action_name).and_return("change_locale")
      expect(controller.send(:skip_locale_check?)).to be true

      # Test with settings controller
      allow(controller).to receive(:controller_name).and_return("settings")
      allow(controller).to receive(:action_name).and_return("change_locale")
      expect(controller.send(:skip_locale_check?)).to be true
    end

    it "skips check for API routes" do
      allow(controller).to receive(:action_name).and_return("show")  # Any action
      allow(controller).to receive(:request).and_return(double(path: "/api/v1/users"))
      expect(controller.send(:skip_locale_check?)).to be true
    end

    it "does not skip for regular routes" do
      allow(controller).to receive(:controller_name).and_return("restaurants")
      allow(controller).to receive(:action_name).and_return("index")
      allow(controller).to receive(:request).and_return(double(path: "/restaurants"))
      expect(controller.send(:skip_locale_check?)).to be false
    end
  end
end
