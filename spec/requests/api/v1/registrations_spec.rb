require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST /api/v1/register' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a new user' do
        freeze_time do
          post '/api/v1/register',
            params: valid_params.to_json,
            headers: {
              'CONTENT_TYPE' => 'application/json',
              'ACCEPT' => 'application/json'
            }

          expect(response).to have_http_status(:success)

          json = JSON.parse(response.body)
          expect(json['status']).to eq('success')
          expect(json['data']).to include(
            'type' => 'user',
            'attributes' => include(
              'email' => 'test@example.com'
            )
          )
          expect(json['meta']).to include(
            'timestamp' => Time.current.iso8601,
            'token' => be_present
          )
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            email: '',  # Empty email should trigger validation
            password: 'short',  # Too short password
            password_confirmation: 'not-matching'  # Non-matching confirmation
          }
        }
      end

      it 'returns validation errors' do
        post '/api/v1/register',
          params: invalid_params.to_json,
          headers: {
            'CONTENT_TYPE' => 'application/json',
            'ACCEPT' => 'application/json'
          }

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['errors']).to include(
          include(
            'code' => 'validation_error',
            'detail' => be_present,
            'source' => include('pointer' => '/data/attributes/email')
          )
        )
        expect(json['meta']).to include('timestamp' => be_present)
      end
    end

    context 'when user is created but not activated' do
      let(:valid_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      before do
        allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
      end

      it 'returns unauthorized with activation message' do
        post '/api/v1/register',
          params: valid_params.to_json,
          headers: {
            'CONTENT_TYPE' => 'application/json',
            'ACCEPT' => 'application/json'
          }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['errors']).to include(
          include(
            'code' => 'inactive_user',
            'detail' => 'User is not activated',
            'source' => include('pointer' => '/data/attributes/status')
          )
        )
        expect(json['meta']).to include('timestamp' => be_present)
      end
    end
  end
end
