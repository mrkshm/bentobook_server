require 'rails_helper'

RSpec.describe 'Api::V1::Profiles', type: :request do
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:test_image) do
    fixture_file_upload(
      Rails.root.join('spec/fixtures/test_image.jpg'),
      'image/jpeg',
      true
    )
  end
  let(:headers) { sign_in_with_token(user) }

  after(:each) do
    # Clean up any processed images
    ActiveStorage::Blob.unattached.find_each(&:purge)
    FileUtils.rm_rf(Dir["#{Rails.root}/tmp/storage/*"])
  end

  describe 'GET /api/v1/profile' do
    it 'returns the user profile' do
      profile = user.create_profile!(
        username: 'testuser',
        preferred_theme: 'light',
        preferred_language: 'en'
      )

      get '/api/v1/profile', headers: headers.merge({
        'Accept' => 'application/json'
      })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(json_response['data']['id']).to eq(profile.id.to_s)
      expect(json_response['data']['type']).to eq('profile')
      expect(json_response['data']['attributes']).to include(
        'email' => user.email,
        'username' => 'testuser',
        'preferred_theme' => 'light',
        'preferred_language' => 'en'
      )
      expect(json_response['meta']).to include('timestamp')
    end
  end

  describe 'PATCH /api/v1/profile/avatar' do
    it 'updates the avatar successfully' do
      profile = user.create_profile!(username: 'testuser')

      patch '/api/v1/profile/avatar',
            params: { avatar: test_image },
            headers: headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      
      # Verify both variants are attached
      profile.reload
      expect(profile.avatar_medium).to be_attached
      expect(profile.avatar_thumbnail).to be_attached
      
      # Verify content types
      expect(profile.avatar_medium.content_type).to eq('image/webp')
      expect(profile.avatar_thumbnail.content_type).to eq('image/webp')
    end

    it 'replaces existing avatars' do
      profile = user.create_profile!(username: 'testuser')
      
      # Attach initial avatars
      profile.avatar_medium.attach(
        io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
        filename: 'old_medium.webp',
        content_type: 'image/webp'
      )
      profile.avatar_thumbnail.attach(
        io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
        filename: 'old_thumbnail.webp',
        content_type: 'image/webp'
      )

      # Update with new avatar
      patch '/api/v1/profile/avatar',
            params: { avatar: test_image },
            headers: headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:ok)
      profile.reload

      # Verify new attachments
      expect(profile.avatar_medium.filename.to_s).not_to eq('old_medium.webp')
      expect(profile.avatar_thumbnail.filename.to_s).not_to eq('old_thumbnail.webp')
    end

    it 'handles missing avatar parameter' do
      user.create_profile!(username: 'testuser')

      patch '/api/v1/profile/avatar',
            headers: headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['status']).to eq('error')
      expect(json_response['errors'].first['detail']).to eq(['No avatar provided'])
    end

    it 'handles invalid file type' do
      user.create_profile!(username: 'testuser')
      invalid_file = fixture_file_upload(
        Rails.root.join('spec/fixtures/test.txt'),
        'text/plain'
      )

      patch '/api/v1/profile/avatar',
            params: { avatar: invalid_file },
            headers: headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['status']).to eq('error')
      expect(json_response['errors'].first['detail']).to eq(['Invalid file type'])
    end
  end

  describe 'DELETE /api/v1/profile/avatar' do
    context 'when avatars exist' do
      let(:profile) { user.create_profile!(username: 'testuser') }

      before do
        profile.avatar_medium.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'medium.webp',
          content_type: 'image/webp'
        )
        profile.avatar_thumbnail.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'thumbnail.webp',
          content_type: 'image/webp'
        )
      end

      it 'removes both avatars' do
        delete '/api/v1/profile/avatar', headers: headers.merge({
          'Accept' => 'application/json'
        })

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        
        profile.reload
        expect(profile.avatar_medium).not_to be_attached
        expect(profile.avatar_thumbnail).not_to be_attached
      end
    end

    context 'when no avatars exist' do
      before { user.create_profile!(username: 'testuser') }

      it 'returns an error' do
        delete '/api/v1/profile/avatar', headers: headers.merge({
          'Accept' => 'application/json'
        })

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'].first['detail']).to eq(['No avatar to delete'])
      end
    end
  end

  describe 'GET /api/v1/profiles/search' do
    it 'returns matching profiles excluding current user' do
      user.create_profile!(username: 'ouruser')

      # Create some other profiles to search
      other_user1 = create(:user, email: 'test@example.com')
      other_user2 = create(:user, email: 'another@example.com')
      other_user1.create_profile!(username: 'testuser1')
      other_user2.create_profile!(username: 'testuser2')

      # Search by username
      get '/api/v1/profiles/search', params: { query: 'testuser1' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)

      # Search by email
      get '/api/v1/profiles/search', params: { query: 'test@example' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'].first['attributes']['email']).to eq('test@example.com')
    end

    it 'returns empty results for no matches' do
      get '/api/v1/profiles/search', params: { query: 'nonexistent' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_empty
    end
  end

  describe 'PATCH /api/v1/profile/locale' do
    it 'updates the preferred language' do
      profile = user.create_profile!(
        username: 'testuser',
        preferred_language: 'en'
      )

      patch '/api/v1/profile/locale',
            params: { locale: 'fr' }.to_json,
            headers: headers.merge({
              'Accept' => 'application/json',
              'Content-Type' => 'application/json'
            })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(json_response['data']['attributes']['preferred_language']).to eq('fr')

      # Verify the database was updated
      profile.reload
      expect(profile.preferred_language).to eq('fr')
    end

    it 'rejects invalid locales' do
      patch '/api/v1/profile/locale',
            params: { locale: 'invalid' }.to_json,
            headers: headers.merge({
              'Accept' => 'application/json',
              'Content-Type' => 'application/json'
            })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['status']).to eq('error')
      expect(json_response['errors'].first['detail']).to eq(['Invalid locale. Valid options are: en, fr'])
    end
  end
end
