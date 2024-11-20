require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Profiles API', type: :request do
  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }

  before do
    # Set host for URL generation
    Rails.application.config.action_mailer.default_url_options = { host: 'example.com' }
  end

  path '/api/v1/profile' do
    get 'Retrieves the user profile' do
      tags 'Profiles'
      produces 'application/json'
      security [ bearer_auth: [] ]

      response '200', 'profile found' do
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['type']).to eq('profile')
          expect(data['data']['id']).to eq(user.profile.id.to_s)
          expect(data['data']['attributes']).to include('avatar_url')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    patch 'Updates the user profile' do
      tags 'Profiles'
      consumes 'application/json'
      produces 'application/json'
      security [ bearer_auth: [] ]
      parameter name: :profile, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          first_name: { type: :string },
          last_name: { type: :string },
          about: { type: :string },
          avatar: { type: :string }
        }
      }

      response '200', 'profile updated' do
        let(:Authorization) { "Bearer #{token}" }
        let(:profile) { { first_name: 'John', last_name: 'Doe' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['first_name']).to eq('John')
          expect(data['data']['attributes']['last_name']).to eq('Doe')
          expect(data['data']['attributes']).to include('avatar_url')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:profile) { { first_name: 'A' * 51 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors']).to be_an(Array)
          expect(data['errors'].first).to include(
            'code' => 'general_error',
            'detail' => 'First name is too long (maximum is 50 characters)'
          )
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:profile) { { first_name: 'John' } }
        run_test!
      end
    end
  end
end
