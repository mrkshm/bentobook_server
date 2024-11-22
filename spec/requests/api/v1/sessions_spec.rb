require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  let(:user) { create(:user, password: 'password123') }
  let(:password) { 'password123' }
  let(:mobile_user_agent) { "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1" }
  let(:desktop_user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36" }

  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body)
  end

  describe 'POST /api/v1/sessions' do
    context 'with valid credentials' do
      it 'returns device info for mobile device' do

        post '/api/v1/sessions',
          params: { user: { email: user.email, password: password } }.to_json,
          headers: {
            'User-Agent' => mobile_user_agent,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }

        expect(response).to have_http_status(:ok)
        expect(json_response.dig('data', 'device_info')).to include(
          'type' => 'mobile',
          'device' => include('Safari'),
          'platform' => include('iOS')
        )
      end

      it 'returns device info for desktop device' do
        post '/api/v1/sessions',
          params: { user: { email: user.email, password: password } }.to_json,
          headers: {
            'User-Agent' => desktop_user_agent,
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }

        expect(response).to have_http_status(:ok)
        expect(json_response.dig('data', 'device_info')).to include(
          'type' => 'desktop',
          'device' => include('Chrome'),
          'platform' => include('macOS')
        )
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized' do

        post '/api/v1/sessions',
          params: { user: { email: user.email, password: 'wrong' } }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/sessions' do
    let!(:current_session) { create(:user_session, user: user) }
    let!(:other_session) { create(:user_session, user: user) }

    context 'when authenticated' do
      before do
        sign_in_with_token(user, current_session)
        get '/api/v1/sessions', headers: @headers.merge({ 'Accept' => 'application/json' })
      end

      it 'lists all active sessions' do
        expect(response).to have_http_status(:ok)
        expect(json_response['sessions'].length).to eq(2)
        expect(json_response['sessions'].first).to include(
          'device_info',
          'last_used_at',
          'suspicious'
        )
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/sessions', headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/sessions/:id' do
    let!(:current_session) { create(:user_session, user: user) }
    let!(:other_session) { create(:user_session, user: user) }

    context 'when authenticated' do
      before do
        sign_in_with_token(user, current_session)
      end

      it 'revokes another session' do

        delete "/api/v1/sessions/#{other_session.id}", headers: @headers.merge({ 'Accept' => 'application/json' })

        expect(response).to have_http_status(:ok)
        expect(other_session.reload).not_to be_active
      end

      it 'prevents revoking current session' do

        delete "/api/v1/sessions/#{current_session.id}", headers: @headers.merge({ 'Accept' => 'application/json' })

        expect(response).to have_http_status(:bad_request)
        expect(current_session.reload).to be_active
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do

        delete "/api/v1/sessions/#{other_session.id}", headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/sessions' do
    let!(:current_session) { create(:user_session, user: user) }
    let!(:other_sessions) { create_list(:user_session, 3, user: user) }

    context 'when authenticated' do
      before do
        sign_in_with_token(user, current_session)
      end

      it 'revokes all sessions except current' do

        delete '/api/v1/sessions', headers: @headers.merge({ 'Accept' => 'application/json' })
        expect(response).to have_http_status(:ok)
        expect(current_session.reload).to be_active
        other_sessions.each do |session|
          expect(session.reload).not_to be_active
        end
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do

        delete '/api/v1/sessions', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
