require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Sessions API' do
  path '/api/v1/sessions' do
    post 'Creates a session' do
      tags 'Sessions'
      security []  # Explicitly state that no security is required
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            },
            required: [ 'email', 'password' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'session created' do
        let(:user) { create(:user, password: 'password123') }
        let(:user_params) { { user: { email: user.email, password: 'password123' } } }

        before do
          # Create user before running test
          user
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']['code']).to eq(200)
          expect(data['status']['message']).to eq('Logged in successfully.')
          expect(data['data']).to include('token', 'device_info')
          expect(data['data']['device_info']).to include('client_name', 'device', 'last_ip')
          expect(data['data']['user']).to include('email', 'id')
        end
      end

      response '401', 'invalid credentials' do
        let(:user) { create(:user, password: 'password123') }
        let(:user_params) { { user: { email: user.email, password: 'wrong' } } }

        before do
          # Create user before running test
          user
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['status']['code']).to eq(401)
          expect(data['status']['message']).to eq('Invalid email or password.')
        end
      end
    end

    get 'Lists all active sessions' do
      tags 'Sessions'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'sessions found' do
        let(:user) { create(:user) }
        let(:current_session) { create(:user_session, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user, current_session)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['sessions'].length).to eq(1)
          expect(data['sessions'].first).to include(
            'device_info',
            'last_used_at',
            'suspicious'
          )
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end

    delete 'Revokes all other sessions' do
      tags 'Sessions'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'sessions revoked' do
        let(:user) { create(:user) }
        let(:current_session) { create(:user_session, user: user) }
        let!(:other_sessions) { create_list(:user_session, 3, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user, current_session)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['meta']['message']).to eq('All other sessions revoked successfully.')
          expect(current_session.reload).to be_active
          other_sessions.each do |session|
            expect(session.reload).not_to be_active
          end
        end
      end
    end
  end

  path '/api/v1/session' do
    delete 'Logs out current session' do
      tags 'Sessions'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'logged out successfully' do
        let(:user) { create(:user) }
        let(:current_session) { create(:user_session, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user, current_session)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['meta']['message']).to eq('Logged out successfully.')
          expect(current_session.reload).not_to be_active
        end
      end
    end
  end

  path '/api/v1/refresh_token' do
    post 'Refreshes current session token' do
      tags 'Sessions'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'token refreshed' do
        let(:user) { create(:user) }
        let(:current_session) { create(:user_session, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user, current_session)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['attributes']).to include('token', 'device_info')
          expect(data['data']['attributes']['device_info']).to include(
            'client_name',
            'device',
            'last_ip',
            'last_used_at',
            'platform',
            'type'
          )
        end
      end

      response '401', 'invalid session' do
        let(:user) { create(:user) }
        let(:current_session) { create(:user_session, user: user, active: false) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user, current_session)}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to include('code' => 401)
        end
      end
    end
  end
end
