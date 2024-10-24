require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  include AuthHelpers

  describe "POST /api/v1/users/sign_in" do
    let(:password) { 'password123' }
    let(:user) { create(:user, password: password) }

    context "with valid credentials" do
      it "returns a success response with user data and token" do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: password } },
             as: :json

        # Debugging: Output response body if test fails
        puts response.body unless response.successful?

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('status', 'data', 'token')
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Logged in successfully.')
        expect(json_response['data']).to include('id', 'email', 'created_at')
        expect(json_response['token']).to be_present
      end
    end

    context "with invalid credentials" do
      it "returns an unauthorized response" do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: 'wrong_password' } },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/users/sign_out" do
    let(:password) { 'password123' }
    let(:user) { create(:user, password: password) }

    context "when user is logged in" do
      it "returns a success response" do
        # Sign in the user to obtain a token
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: password } },
             as: :json

        token = JSON.parse(response.body)['token']

        # Use the token in the Authorization header for the sign_out request
        delete "/api/v1/users/sign_out",
               headers: { 'Authorization' => "Bearer #{token}" },
               as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq(200)
        expect(json_response['message']).to eq('Logged out successfully.')
      end
    end

    context "when user is not logged in" do
      it "returns an unauthorized response" do
        delete "/api/v1/users/sign_out", as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq(401)
        expect(json_response['message']).to eq("Couldn't find an active session.")
      end
    end
  end
end
