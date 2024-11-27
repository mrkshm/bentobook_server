require 'rails_helper'

RSpec.describe 'Api::V1::Profiles', type: :request do
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
  end

  let(:test_image) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg')
  end

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
    Rails.logger.info "Test setup: Headers after sign_in: #{@headers.inspect}"
  end

  after(:each) do
    # Clean up any processed images
    ActiveStorage::Blob.unattached.find_each(&:purge)
    FileUtils.rm_rf(Dir["#{Rails.root}/tmp/storage/*"])
  end

  describe 'GET /api/v1/profile' do
    it 'returns the user profile' do
      # Create profile through the normal user association
      profile = user.create_profile!(
        username: 'testuser',
        preferred_theme: 'light',
        preferred_language: 'en'
      )

      get '/api/v1/profile', headers: @headers.merge({
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

    it 'returns avatar URLs when avatar is present' do
      # Create profile with avatar
      profile = user.create_profile!(
        username: 'testuser',
        preferred_theme: 'light',
        preferred_language: 'en'
      )

      # Attach avatar using the same approach as the factory trait
      profile.avatar.attach(
        io: File.open(Rails.root.join('spec/fixtures/avatar.jpg')),
        filename: 'avatar.jpg',
        content_type: 'image/jpeg'
      )

      get '/api/v1/profile', headers: @headers.merge({
        'Accept' => 'application/json'
      })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')

      avatar_urls = json_response['data']['attributes']['avatar_urls']
      expect(avatar_urls).to be_present
      expect(avatar_urls).to include(
        'thumbnail',
        'small',
        'medium',
        'large',
        'original'
      )

      # Verify URLs are properly formatted
      avatar_urls.values.each do |url|
        expect(url).to match(/^http/)
        expect(url).to include('rails/active_storage')
      end
    end
  end

  describe 'PATCH /api/v1/profile' do
    it 'updates the profile' do
      # Create profile through the normal user association
      profile = user.create_profile!(
        username: 'oldusername',
        preferred_theme: 'light',
        preferred_language: 'en'
      )

      patch '/api/v1/profile',
            params: {
              profile: {
                username: 'newusername',
                first_name: 'John',
                last_name: 'Doe'
              }
            },
            headers: @headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')

      # Verify the response shows the updated values
      expect(json_response['data']['attributes']).to include(
        'username' => 'newusername',
        'first_name' => 'John',
        'last_name' => 'Doe'
      )

      # Verify the database was actually updated
      profile.reload
      expect(profile.username).to eq('newusername')
      expect(profile.first_name).to eq('John')
      expect(profile.last_name).to eq('Doe')
    end

    it 'handles validation errors' do
      profile = user.create_profile!(username: 'testuser')
      other_user = create(:user)
      other_profile = create(:profile, username: 'taken_username', user: other_user)

      patch '/api/v1/profile',
            params: {
              profile: { username: 'taken_username' }
            },
            headers: @headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['status']).to eq('error')
      expect(json_response['errors']).to be_present
    end

    it 'updates the avatar' do
      profile = user.create_profile!(username: 'testuser')
      test_image = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg')

      patch '/api/v1/profile',
            params: {
              profile: {
                avatar: test_image
              }
            },
            headers: @headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(json_response['data']['attributes']['avatar_urls']).to be_present
    end
  end

  describe 'GET /api/v1/profiles/search' do
    it 'returns matching profiles excluding current user' do
      # Create our profile
      our_profile = user.create_profile!(username: 'ouruser')

      # Create some other profiles to search
      other_user1 = create(:user, email: 'test@example.com')
      other_user2 = create(:user, email: 'another@example.com')
      other_profile1 = other_user1.create_profile!(username: 'testuser1')
      other_profile2 = other_user2.create_profile!(username: 'testuser2')

      # Search by username
      get '/api/v1/profiles/search', params: { query: 'testuser' }, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(2)

      # Search by email
      get '/api/v1/profiles/search', params: { query: 'test@example' }, headers: @headers
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'].first['attributes']['email']).to eq('test@example.com')
    end

    it 'returns empty results for no matches' do
      get '/api/v1/profiles/search', params: { query: 'nonexistent' }, headers: @headers
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
            params: { locale: 'fr' },
            headers: @headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(json_response['data']['attributes']['preferred_language']).to eq('fr')

      # Verify the database was updated
      profile.reload
      expect(profile.preferred_language).to eq('fr')
    end

    it 'rejects invalid locales' do
      profile = user.create_profile!(username: 'testuser')

      patch '/api/v1/profile/locale',
            params: { locale: 'invalid' },
            headers: @headers.merge({
              'Accept' => 'application/json'
            })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['status']).to eq('error')
      expect(json_response['errors'].first['detail']).to eq('Invalid locale. Valid options are: en, fr')
    end
  end
end
