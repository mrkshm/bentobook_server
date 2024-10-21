require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Profiles API', type: :request do
  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }

  path '/api/v1/profile' do
    get 'Retrieves the user profile' do
      tags 'Profiles'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'profile found' do
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(user.profile.id)
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
      security [bearer_auth: []]
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
          expect(data['first_name']).to eq('John')
          expect(data['last_name']).to eq('Doe')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:profile) { { first_name: 'A' * 51 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
          expect(data).to have_key('errors')
          expect(data['errors']).to have_key('first_name')
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
