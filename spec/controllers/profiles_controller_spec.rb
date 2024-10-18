require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:profile) { user.profile }
  let!(:other_profile) { create(:profile, username: 'existing_username') }

  before do
    sign_in user
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { first_name: "New Name" } }

      it "updates the requested profile" do
        put :update, params: { profile: new_attributes }
        profile.reload
        expect(profile.first_name).to eq("New Name")
      end

      it "redirects to the profile" do
        put :update, params: { profile: new_attributes }
        expect(response).to redirect_to(profile_path)
      end
    end

    context "with invalid params" do
      let(:invalid_attributes) { { username: 'existing_username' } }

      it "returns an unprocessable entity status" do
        put :update, params: { profile: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        put :update, params: { profile: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "PUT #change_locale" do
    it "changes the locale" do
      put :change_locale, params: { locale: 'fr' }
      expect(session[:locale]).to eq('fr')
    end

    it "redirects to the profile path" do
      put :change_locale, params: { locale: 'fr' }
      expect(response).to redirect_to(profile_path)
    end

    it "sets a flash notice" do
      put :change_locale, params: { locale: 'fr' }
      expect(flash[:notice]).to be_present
    end

    context "with invalid locale" do
      it "does not change the locale" do
        put :change_locale, params: { locale: 'invalid' }
        expect(session[:locale]).to be_nil
      end

      it "sets a flash alert" do
        put :change_locale, params: { locale: 'invalid' }
        expect(flash[:alert]).to be_present
      end
    end
  end
end
