require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
      super
    end
  end

  describe "#after_sign_in_path_for" do
    let(:user) { create(:user) }

    context "when in a native app" do
      it "returns the home dashboard path" do
        allow(controller).to receive(:turbo_native_app?).and_return(true)
        expect(controller.after_sign_in_path_for(user)).to eq(home_dashboard_path)
      end
    end

    context "when in a web app" do
      it "returns the restaurants path" do
        allow(controller).to receive(:turbo_native_app?).and_return(false)
        expect(controller.after_sign_in_path_for(user)).to eq(restaurants_path)
      end
    end
  end
end
