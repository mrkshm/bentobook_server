require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Registrations API' do
  path '/api/v1/register' do
    post 'Creates a new user account' do
      tags 'Registration'
      security [] # No auth required for registration
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: [ 'email', 'password', 'password_confirmation' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'user registered successfully' do
        let(:user_params) do
          {
            user: {
              email: 'test@example.com',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']).to include(
            'type' => 'user',
            'attributes' => include(
              'email' => 'test@example.com'
            )
          )
          expect(data['meta']).to include(
            'timestamp',
            'token'
          )
          expect(data['meta']['token']).to be_present
        end
      end

      response '422', 'invalid request' do
        let(:user_params) do
          {
            user: {
              email: '',
              password: 'short',
              password_confirmation: 'not-matching'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors']).to be_present
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      response '500', 'internal server error' do
        let(:user_params) { { invalid: 'params' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:internal_server_error)
          expect(data['status']).to eq('error')
          expect(data['errors']).to eq([ {
            'code' => 'general_error',
            'detail' => 'param is missing or the value is empty or invalid: user'
          } ])
          expect(data['meta']['timestamp']).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/)
        end
      end
    end
  end
end
