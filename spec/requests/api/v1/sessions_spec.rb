require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  include AuthHelpers

  let(:password) { 'password123' }
  let(:user) { create(:user, password: password) }
  let(:client_info) { { name: 'Chrome on macOS', platform: 'web' } }

  describe "POST /api/v1/users/sign_in" do
    context "with valid credentials" do
      it "returns a success response with user data, token, and creates user session" do
        expect {
          post "/api/v1/users/sign_in",
               params: { user: { email: user.email, password: password }, client: client_info },
               as: :json
        }.to change(UserSession, :count).by(1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        # Check response structure
        expect(json_response).to include('status', 'data', 'token')
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Logged in successfully.')
        expect(json_response['data']).to include('id', 'email', 'created_at')
        expect(json_response['token']).to be_present

        # Verify user session was created with client info
        user_session = UserSession.last
        expect(user_session.client_name).to eq(client_info[:name])
        expect(user_session.active).to be true
      end

      it "includes expiration time in JWT payload" do
        post "/api/v1/users/sign_in",
             params: { user: { email: user.email, password: password }, client: client_info },
             as: :json

        token = JSON.parse(response.body)['token']
        decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key, true, { algorithm: 'HS256' }).first

        expect(decoded_token).to include('exp')
        expect(decoded_token['exp']).to be > Time.now.to_i
        expect(decoded_token['exp']).to be <= (Time.now + 24.hours).to_i
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

  describe "POST /api/v1/refresh_token" do
    let(:user_session) { create(:user_session, user: user, client_name: client_info[:name]) }
    let(:expired_token) do
      payload = {
        'sub' => user.id,
        'jti' => user_session.jti,
        'exp' => 1.minute.ago.to_i
      }
      JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key, 'HS256')
    end

    it "refreshes an expired token" do
      post "/api/v1/refresh_token",
           headers: { 'Authorization' => "Bearer #{expired_token}" },
           as: :json

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['token']).to be_present
      expect(json_response['token']).not_to eq(expired_token)

      # Verify the session was updated
      user_session.reload
      expect(user_session.last_used_at).to be_within(1.second).of(Time.current)
    end

    it "rejects refresh for revoked session" do
      user_session.update!(active: false)

      post "/api/v1/refresh_token",
           headers: { 'Authorization' => "Bearer #{expired_token}" },
           as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/users/sign_out" do
    let(:user_session) { create(:user_session, user: user, client_name: client_info[:name]) }
    let(:valid_token) do
      begin
        payload = {
          'sub' => user.id,
          'jti' => user_session.jti,
          'exp' => 24.hours.from_now.to_i
        }
        Rails.logger.debug "Test payload: #{payload.inspect}"
        token = JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key, 'HS256')
        Rails.logger.debug "Generated token: #{token}"
        token
      rescue => e
        Rails.logger.error "Error generating token: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise
      end
    end

    it "revokes the user session" do
      begin
        Rails.logger.debug "User: #{user.inspect}"
        Rails.logger.debug "User Session: #{user_session.inspect}"
        Rails.logger.debug "Token for request: #{valid_token}"

        delete "/api/v1/users/sign_out",
               headers: { 'Authorization' => "Bearer #{valid_token}" },
               as: :json
      rescue => e
        Rails.logger.error "Error in test: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise
      end

      expect(response).to have_http_status(:ok)
      user_session.reload
      expect(user_session.active).to be false
    end

    it "handles multiple sessions for the same user" do
      other_session = create(:user_session, user: user, client_name: 'Other Device')

      delete "/api/v1/users/sign_out",
             headers: { 'Authorization' => "Bearer #{valid_token}" },
             as: :json

      expect(response).to have_http_status(:ok)

      # Verify only the current session was revoked
      user_session.reload
      other_session.reload
      expect(user_session.active).to be false
      expect(other_session.active).to be true
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
