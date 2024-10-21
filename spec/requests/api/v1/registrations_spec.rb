require 'swagger_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  path '/api/v1/users' do
    post 'Creates a new user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      security []
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: ['email', 'password', 'password_confirmation']
          }
        }
      }

      response '200', 'user created' do
        let(:user) { { user: { email: 'test@example.com', password: 'password123', password_confirmation: 'password123' } } }
        run_test! do |response|
          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          puts json_response # Debugging: Inspect the response
          expect(json_response['status']['message']).to eq('Signed up successfully.')

          # Parse the 'data' field separately
          user_data = JSON.parse(json_response['data'])
          expect(user_data['email']).to eq('test@example.com')

          expect(json_response['token']).to be_a(String)
        end
      end

      response '422', 'invalid request' do
        let(:user) { { user: { email: 'invalid', password: 'short', password_confirmation: 'mismatch' } } }
        run_test! do |response|
          expect(response.status).to eq(422)
          json_response = JSON.parse(response.body)
          expect(json_response['status']['message']).to eq("User couldn't be created successfully.")
          expect(json_response['errors']).to be_present
        end
      end

      response '401', 'user created but not activated' do
        before do
          allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
        end

        let(:user) { { user: { email: 'inactive@example.com', password: 'password123', password_confirmation: 'password123' } } }
        run_test! do |response|
          expect(response.status).to eq(401)
          json_response = JSON.parse(response.body)
          expect(json_response['status']['message']).to eq('User created but not activated')
          expect(json_response['errors']).to include('User is not activated')
        end
      end
    end
  end
end
