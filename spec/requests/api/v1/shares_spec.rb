require 'rails_helper'

RSpec.describe 'Api::V1::Shares', type: :request do
  let(:user) { create(:user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
  end

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
  end

  describe 'GET /api/v1/shares' do
    context 'when user has shares' do
      let!(:other_user) { create(:user) }
      let!(:list) { create(:list, owner: other_user) }
      let!(:share) { create(:share, creator: other_user, recipient: user, shareable: list) }
      let!(:other_share) { create(:share, creator: user, recipient: other_user, shareable: create(:list, owner: user)) }

      it 'returns only shares where user is recipient' do
        get '/api/v1/shares', headers: @headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['id']).to eq(share.id.to_s)
      end
    end

    context 'when user has no shares' do
      it 'returns an empty array' do
        get '/api/v1/shares', headers: @headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
      end
    end
  end

  describe 'POST /api/v1/lists/:list_id/shares' do
    let!(:list) { create(:list, owner: user) }
    let!(:recipients) { create_list(:user, 2) }
    let(:valid_params) do
      {
        recipient_ids: recipients.map(&:id),
        share: {
          permission: 'view',
          reshareable: true
        }
      }
    end

    context 'when user owns the list' do
      it 'creates shares for all recipients' do
        expect {
          post "/api/v1/lists/#{list.id}/shares",
               params: valid_params,
               headers: @headers
        }.to change(Share, :count).by(2)

        expect(response).to have_http_status(:created)
        expect(json_response['data'].length).to eq(2)
      end
    end

    context 'when user has edit permission and reshareable' do
      let!(:list_owner) { create(:user) }
      let!(:list) { create(:list, owner: list_owner) }
      let!(:existing_share) do
        create(:share,
               creator: list_owner,
               recipient: user,
               shareable: list,
               permission: :edit,
               reshareable: true,
               status: :accepted)
      end

      it 'allows creating new shares' do
        expect {
          post "/api/v1/lists/#{list.id}/shares",
               params: valid_params,
               headers: @headers
        }.to change(Share, :count).by(2)

        expect(response).to have_http_status(:created)
      end
    end

    context 'when user does not have permission' do
      let!(:list_owner) { create(:user) }
      let!(:list) { create(:list, owner: list_owner) }

      it 'returns unauthorized' do
        post "/api/v1/lists/#{list.id}/shares",
             params: valid_params,
             headers: @headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/shares/:id/accept' do
    let!(:other_user) { create(:user) }
    let!(:list) { create(:list, owner: other_user) }
    let!(:share) { create(:share, creator: other_user, recipient: user, shareable: list, status: :pending) }

    context 'when user is the recipient' do
      it 'accepts the share' do
        post "/api/v1/shares/#{share.id}/accept", headers: @headers
        expect(response).to have_http_status(:ok)
        expect(share.reload.status).to eq('accepted')
      end
    end

    context 'when user is not the recipient' do
      let!(:share) { create(:share, creator: other_user, recipient: create(:user), shareable: list) }

      it 'returns unauthorized' do
        post "/api/v1/shares/#{share.id}/accept", headers: @headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/shares/:id/decline' do
    let!(:other_user) { create(:user) }
    let!(:list) { create(:list, owner: other_user) }
    let!(:share) { create(:share, creator: other_user, recipient: user, shareable: list, status: :pending) }

    context 'when user is the recipient' do
      it 'declines the share' do
        post "/api/v1/shares/#{share.id}/decline", headers: @headers
        expect(response).to have_http_status(:ok)
        expect(share.reload.status).to eq('rejected')
      end
    end

    context 'when user is not the recipient' do
      let!(:share) { create(:share, creator: other_user, recipient: create(:user), shareable: list) }

      it 'returns unauthorized' do
        post "/api/v1/shares/#{share.id}/decline", headers: @headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/shares/accept_all' do
    let!(:other_user) { create(:user) }
    let!(:list1) { create(:list, owner: other_user) }
    let!(:list2) { create(:list, owner: other_user) }

    context 'when user has pending shares' do
      let!(:share1) { create(:share, creator: other_user, recipient: user, shareable: list1, status: :pending) }
      let!(:share2) { create(:share, creator: other_user, recipient: user, shareable: list2, status: :pending) }
      let!(:accepted_share) { create(:share, creator: other_user, recipient: user, shareable: create(:list), status: :accepted) }

      it 'accepts all pending shares' do
        post '/api/v1/shares/accept_all', headers: @headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(2)
        expect(share1.reload.status).to eq('accepted')
        expect(share2.reload.status).to eq('accepted')
        expect(accepted_share.reload.status).to eq('accepted')
      end
    end

    context 'when user has no pending shares' do
      it 'returns success with message' do
        post '/api/v1/shares/accept_all', headers: @headers
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('No pending shares to accept')
      end
    end
  end

  describe 'POST /api/v1/shares/decline_all' do
    let!(:other_user) { create(:user) }
    let!(:list1) { create(:list, owner: other_user) }
    let!(:list2) { create(:list, owner: other_user) }

    context 'when user has pending shares' do
      let!(:share1) { create(:share, creator: other_user, recipient: user, shareable: list1, status: :pending) }
      let!(:share2) { create(:share, creator: other_user, recipient: user, shareable: list2, status: :pending) }
      let!(:accepted_share) { create(:share, creator: other_user, recipient: user, shareable: create(:list), status: :accepted) }

      it 'declines all pending shares' do
        post '/api/v1/shares/decline_all', headers: @headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(2)
        expect(share1.reload.status).to eq('rejected')
        expect(share2.reload.status).to eq('rejected')
        expect(accepted_share.reload.status).to eq('accepted')
      end
    end

    context 'when user has no pending shares' do
      it 'returns success with message' do
        post '/api/v1/shares/decline_all', headers: @headers
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('No pending shares to decline')
      end
    end
  end

  describe 'DELETE /api/v1/shares/:id' do
    let!(:other_user) { create(:user) }
    let!(:list) { create(:list, owner: other_user) }

    context 'when user is the recipient' do
      let!(:share) { create(:share, creator: other_user, recipient: user, shareable: list) }

      it 'deletes the share' do
        expect {
          delete "/api/v1/shares/#{share.id}", headers: @headers
        }.to change(Share, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is the creator' do
      let!(:share) { create(:share, creator: user, recipient: other_user, shareable: create(:list, owner: user)) }

      it 'deletes the share' do
        expect {
          delete "/api/v1/shares/#{share.id}", headers: @headers
        }.to change(Share, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is neither creator nor recipient' do
      let!(:share) { create(:share, creator: other_user, recipient: create(:user), shareable: list) }

      it 'returns unauthorized' do
        delete "/api/v1/shares/#{share.id}", headers: @headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
