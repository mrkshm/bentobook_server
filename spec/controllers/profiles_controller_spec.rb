require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  include ActionDispatch::TestProcess
  let(:user) { create(:user) }
  let!(:profile) { user.create_profile!(first_name: "John", last_name: "Doe") }
  let!(:other_user) { create(:user) }
  let!(:other_profile) { other_user.create_profile!(username: 'existing_username') }
  let(:test_image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }

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

      it "handles avatar upload" do
        expect {
          put :update, params: { profile: new_attributes.merge(avatar: test_image) }
          profile.reload
        }.to change { profile.avatar.attached? }.from(false).to(true)
      end

      describe "locale handling" do
        it "updates session locale and I18n.locale when preferred_language changes" do
          get :show
          
          expect {
            put :update, params: { profile: { preferred_language: 'fr' } }
          }.to change { session[:locale] }.to('fr')
          
          expect(profile.reload.preferred_language).to eq('fr')
        end

        it "doesn't change locale settings when preferred_language is not provided" do
          get :show
          
          initial_locale = I18n.locale
          
          put :update, params: { profile: { first_name: 'John' } }
          
          aggregate_failures do
            expect(session[:locale].to_s).to eq(initial_locale.to_s)
            expect(I18n.locale).to eq(initial_locale)
          end
        end
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

    context "with invalid locale" do
      it "does not change the locale" do
        put :change_locale, params: { locale: 'invalid' }
        expect(session[:locale]).to be_nil
      end
    end
  end
end
