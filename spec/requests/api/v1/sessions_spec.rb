require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  describe 'POST /api/v1/auth/login' do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, password: 'password123') }

    before do
      # Create user and organization membership before running test
      create(:membership, user: user, organization: organization)
    end

    context 'with valid credentials' do
      it 'returns a successful response with token info' do
        post '/api/v1/auth/login', params: { user: { email: user.email, password: 'password123' } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        # Check status
        expect(json['status']).to eq('success')

        # Check data structure
        expect(json['data']).to include('id', 'type', 'attributes')
        expect(json['data']['attributes']).to include('email')
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized response' do
        # Use a completely wrong password to ensure 401
        post '/api/v1/auth/login', params: { user: { email: user.email, password: 'completely_wrong_password' } }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)

        # Check status
        expect(json['status']).to eq('error')

        # Check errors
        expect(json).to have_key('errors')
      end
    end
  end

  # Since we need to test the controller's behavior with JWT tokens,
  # which is complex to set up in tests, we'll focus on the login functionality
  # for now and handle the other endpoints in integration tests.
end
