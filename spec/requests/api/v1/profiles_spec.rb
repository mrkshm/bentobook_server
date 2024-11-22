require 'rails_helper'

RSpec.describe 'Api::V1::Profiles', type: :request do
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }
  let!(:user_session) { create(:user_session, user: user) }

  describe 'GET /api/v1/authenticated/profile' do
    context 'when authenticated' do
      before do
        sign_in_with_token(user, user_session)
      end

      it 'returns the user profile' do
        get '/api/v1/authenticated/profile', headers: @headers.merge({
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        })

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
