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
    session[:locale] = 'en'
    I18n.locale = :en
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { locale: 'en' }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      get :edit, params: { locale: 'en' }
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { first_name: "New Name" } }

      it "updates the requested profile" do
        put :update, params: { profile: new_attributes, locale: 'en' }
        profile.reload
        expect(profile.first_name).to eq("New Name")
      end

      it "redirects to the profile" do
        put :update, params: { profile: new_attributes, locale: 'en' }
        expect(response).to redirect_to(profile_path(locale: 'en'))
      end

      it "handles avatar upload and creates both sizes" do
        expect {
          put :update, params: { profile: new_attributes.merge(avatar: test_image), locale: 'en' }
          profile.reload
        }.to change { profile.avatar_medium.attached? }.from(false).to(true)
         .and change { profile.avatar_thumbnail.attached? }.from(false).to(true)
      end

      it "replaces existing avatars when uploading a new one" do
        # First upload
        put :update, params: { profile: { avatar: test_image }, locale: 'en' }
        profile.reload
        
        medium_blob_id = profile.avatar_medium.blob.id
        thumbnail_blob_id = profile.avatar_thumbnail.blob.id
        
        # Second upload
        put :update, params: { profile: { avatar: test_image }, locale: 'en' }
        profile.reload
        
        # Check that new blobs were created
        expect(profile.avatar_medium.blob.id).not_to eq(medium_blob_id)
        expect(profile.avatar_thumbnail.blob.id).not_to eq(thumbnail_blob_id)
      end

      describe "locale handling" do
        it "updates session locale and I18n.locale when preferred_language changes" do
          get :show, params: { locale: 'en' }
          
          expect {
            put :update, params: { profile: { preferred_language: 'fr' }, locale: 'en' }
          }.to change { session[:locale] }.from('en').to('fr')
          
          expect(profile.reload.preferred_language).to eq('fr')
        end

        it "doesn't change locale settings when preferred_language is not provided" do
          get :show, params: { locale: 'en' }
          
          initial_locale = I18n.locale
          
          put :update, params: { profile: { first_name: 'John' }, locale: 'en' }
          
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
        put :update, params: { profile: invalid_attributes, locale: 'en' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        put :update, params: { profile: invalid_attributes, locale: 'en' }
        expect(response).to render_template(:edit)
      end
    end

    context "with invalid avatar" do
      let(:invalid_image) { fixture_file_upload('spec/fixtures/invalid.txt', 'text/plain') }

      it "returns an error when uploading an invalid file type" do
        put :update, params: { profile: { avatar: invalid_image }, locale: 'en' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #delete_avatar" do
    before do
      put :update, params: { profile: { avatar: test_image }, locale: 'en' }
      profile.reload
    end

    it "removes both avatar sizes" do
      expect {
        delete :delete_avatar, params: { locale: 'en' }
        profile.reload
      }.to change { profile.avatar_medium.attached? }.from(true).to(false)
       .and change { profile.avatar_thumbnail.attached? }.from(true).to(false)
    end

    it "redirects to edit profile path" do
      delete :delete_avatar, params: { locale: 'en' }
      expect(response).to redirect_to(edit_profile_path(locale: 'en'))
    end
  end

  describe "PUT #change_locale" do
    it "changes the locale" do
      put :change_locale, params: { locale: 'fr' }
      expect(session[:locale]).to eq('fr')
    end

    it "redirects to the profile path" do
      put :change_locale, params: { locale: 'fr' }
      expect(response).to redirect_to(profile_path(locale: 'fr'))
    end

    context "with invalid locale" do
      it "does not change the locale" do
        put :change_locale, params: { locale: 'invalid' }
        expect(session[:locale]).to eq('en')
      end
    end
  end
end
