require 'rails_helper'
require 'stringio'

RSpec.describe ProfilesController, type: :controller do
  include ActionDispatch::TestProcess::FixtureFile
  let(:user) { create(:user, first_name: "John", last_name: "Doe") }
  let(:primary_organization) { create(:organization, name: "Test Org") }
  let(:test_image) { fixture_file_upload('test_image.jpg', 'image/jpeg') }
  let(:test_image_2) { fixture_file_upload('test_image_2.jpg', 'image/jpeg') }

  before do
    sign_in user
    session[:locale] = 'en'
    I18n.locale = :en
    # Create membership for user in organization and ensure it's their primary org
    user.memberships.create!(organization: primary_organization)
    # Force a reload to ensure associations are fresh
    user.reload
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
      let(:user_attributes) { { first_name: "New Name", language: "fr" } }
      let(:organization_attributes) { { name: "New Org Name" } }

      it "updates user attributes" do
        put :update, params: { user: user_attributes, locale: 'en' }
        user.reload
        expect(user.first_name).to eq("New Name")
        expect(user.language).to eq("fr")
      end

      it "updates organization attributes" do
        put :update, params: { organization: organization_attributes, locale: 'en' }
        # Important: We need to reload the organization through the user to get the updated instance
        user.reload
        expect(user.organizations.first.name).to eq("New Org Name")
      end

      it "redirects to the profile" do
        put :update, params: { user: user_attributes, organization: organization_attributes, locale: 'en' }
        expect(response).to redirect_to(profile_path(locale: 'fr'))
      end

      describe "avatar handling" do
        before do
          # Create test content for avatar variants
          medium_file = fixture_file_upload('test_image.jpg', 'image/jpeg')
          medium_content = medium_file.read
          medium_file.rewind

          thumbnail_file = fixture_file_upload('test_image.jpg', 'image/jpeg')
          thumbnail_content = thumbnail_file.read
          thumbnail_file.rewind
          
          # Mock PreprocessAvatarService to return fresh StringIO objects each time
          allow(PreprocessAvatarService).to receive(:call) do
            {
              success: true,
              variants: {
                medium: {
                  io: StringIO.new(medium_content),
                  filename: "avatar_medium.jpg",
                  content_type: "image/jpeg"
                },
                thumbnail: {
                  io: StringIO.new(thumbnail_content),
                  filename: "avatar_thumbnail.jpg",
                  content_type: "image/jpeg"
                }
              }
            }
          end
        end

        it "handles avatar upload and creates both sizes" do
          # Get initial state
          user.reload
          initial_org = user.organizations.first
          expect(initial_org.avatar_medium).not_to be_attached
          expect(initial_org.avatar_thumbnail).not_to be_attached

          # Perform update
          put :update, params: { organization: { avatar: test_image }, locale: 'en' }

          # Verify final state
          user.reload
          updated_org = user.organizations.first
          expect(updated_org.avatar_medium).to be_attached
          expect(updated_org.avatar_thumbnail).to be_attached
        end

        it "replaces existing avatars when uploading a new one" do
          # First upload
          put :update, params: { organization: { avatar: test_image }, locale: 'en' }
          user.reload
          org_after_first = user.organizations.first
          expect(org_after_first.avatar_medium).to be_attached
          expect(org_after_first.avatar_thumbnail).to be_attached
          
          medium_blob_id = org_after_first.avatar_medium.blob.id
          thumbnail_blob_id = org_after_first.avatar_thumbnail.blob.id
          
          # Second upload with a different image
          put :update, params: { organization: { avatar: test_image_2 }, locale: 'en' }
          user.reload
          org_after_second = user.organizations.first
          expect(org_after_second.avatar_medium).to be_attached
          expect(org_after_second.avatar_thumbnail).to be_attached
          
          # Check that new blobs were created
          expect(org_after_second.avatar_medium.blob.id).not_to eq(medium_blob_id)
          expect(org_after_second.avatar_thumbnail.blob.id).not_to eq(thumbnail_blob_id)
        end
      end

      describe "locale handling" do
        it "updates session locale and I18n.locale when language changes" do
          get :show, params: { locale: 'en' }
          
          expect {
            put :update, params: { user: { language: 'fr' }, locale: 'en' }
          }.to change { session[:locale] }.from('en').to('fr')
          
          expect(user.reload.language).to eq('fr')
        end

        it "doesn't change locale settings when language is not provided" do
          get :show, params: { locale: 'en' }
          
          initial_locale = I18n.locale
          
          put :update, params: { organization: { name: 'New Name' }, locale: 'en' }
          
          aggregate_failures do
            expect(session[:locale].to_s).to eq(initial_locale.to_s)
            expect(I18n.locale).to eq(initial_locale)
          end
        end
      end
    end

    context "with invalid params" do
      let(:invalid_user_attributes) { { first_name: '' } }
      let(:invalid_organization_attributes) { { name: '' } }

      before do
        # Ensure validation fails
        allow_any_instance_of(User).to receive(:valid?).and_return(false)
        allow_any_instance_of(Organization).to receive(:valid?).and_return(false)
      end

      it "returns an unprocessable entity status for invalid user attributes" do
        put :update, params: { user: invalid_user_attributes, locale: 'en' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns an unprocessable entity status for invalid organization attributes" do
        put :update, params: { organization: invalid_organization_attributes, locale: 'en' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the edit template" do
        put :update, params: { user: invalid_user_attributes, locale: 'en' }
        expect(response).to render_template(:edit)
      end
    end

    context "with invalid avatar" do
      let(:invalid_image) { fixture_file_upload('invalid.txt', 'text/plain') }

      before do
        allow(PreprocessAvatarService).to receive(:call).and_return({ success: false })
      end

      it "returns an error when uploading an invalid file type" do
        put :update, params: { organization: { avatar: invalid_image }, locale: 'en' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #delete_avatar" do
    before do
      # Set up test variants with StringIO
      medium_file = fixture_file_upload('test_image.jpg', 'image/jpeg')
      medium_content = medium_file.read
      medium_file.rewind

      thumbnail_file = fixture_file_upload('test_image.jpg', 'image/jpeg')
      thumbnail_content = thumbnail_file.read
      thumbnail_file.rewind

      allow(PreprocessAvatarService).to receive(:call).and_return({
        success: true,
        variants: {
          medium: {
            io: StringIO.new(medium_content),
            filename: "avatar_medium.jpg",
            content_type: "image/jpeg"
          },
          thumbnail: {
            io: StringIO.new(thumbnail_content),
            filename: "avatar_thumbnail.jpg",
            content_type: "image/jpeg"
          }
        }
      })

      # Attach avatars first
      put :update, params: { organization: { avatar: test_image }, locale: 'en' }
      user.reload
      @organization = user.organizations.first
      expect(@organization.avatar_medium).to be_attached
      expect(@organization.avatar_thumbnail).to be_attached
    end

    it "removes both avatar sizes" do
      expect {
        delete :delete_avatar, params: { locale: 'en' }
        user.reload
        @organization = user.organizations.first
      }.to change { @organization.avatar_medium.attached? }.from(true).to(false)
       .and change { @organization.avatar_thumbnail.attached? }.from(true).to(false)
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

  describe "GET #search" do
    let!(:other_user) { create(:user) }
    let!(:other_organization) { create(:organization, name: "Other Org") }

    before do
      other_user.memberships.create!(organization: other_organization)
    end

    it "returns matching organizations" do
      get :search, params: { query: "Other", locale: 'en' }, xhr: true
      expect(response).to be_successful
      expect(assigns(:organizations)).to include(other_organization)
    end

    it "excludes the current user's organization" do
      get :search, params: { query: "Test", locale: 'en' }, xhr: true
      expect(assigns(:organizations)).not_to include(primary_organization)
    end

    it "requires XHR request" do
      get :search, params: { query: "Test", locale: 'en' }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
