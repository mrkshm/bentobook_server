require 'rails_helper'

RSpec.describe 'Registrations API', type: :request do
  describe 'POST /api/v1/auth/register' do
    let(:valid_params) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          email: '',
          password: 'short',
          password_confirmation: 'not-matching'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user and returns a JWT token' do
        expect {
          post '/api/v1/auth/register', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        
        # Parse response body
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        
        # Check for JWT token in Authorization header
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to match(/^Bearer /)
        
        # Verify that the user has an organization
        user = User.find_by(email: 'test@example.com')
        expect(user).to be_present
        expect(user.organizations.count).to eq(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a user and returns validation errors' do
        expect {
          post '/api/v1/auth/register', params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['errors']).to be_present
      end
    end

    context 'with missing user parameter' do
      it 'returns an error' do
        post '/api/v1/auth/register', params: { invalid: 'params' }
        
        expect(response).to have_http_status(:internal_server_error)
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
      end
    end
  end
end
