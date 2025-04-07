require 'rails_helper'

RSpec.describe 'Api::V1::Shares', type: :request do
  let(:user) { create(:user) }
  let(:organization) { user.organizations.first }
  
  # Create another organization for testing sharing between organizations
  let(:target_org) { create(:organization) }
  let(:target_org_admin) { create(:user) }
  
  before do
    # Create membership for target_org_admin in target_org
    create(:membership, user: target_org_admin, organization: target_org)
    
    # Set up authentication and current organization
    @auth_headers = sign_in_with_token(user)
    Current.organization = organization
  end
  
  after do
    Current.organization = nil
  end

  describe 'GET /api/v1/shares' do
    context 'when organization has shares' do
      let!(:other_org) { create(:organization) }
      let!(:list) { create(:list, organization: other_org, creator: create(:user)) }
      let!(:share) { create(:share, source_organization: other_org, target_organization: organization, shareable: list) }
      let!(:other_share) { create(:share, source_organization: organization, target_organization: other_org, shareable: create(:list, organization: organization, creator: user)) }

      it 'returns only shares where organization is the target' do
        get '/api/v1/shares', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['id']).to eq(share.id.to_s)
      end
    end

    context 'when organization has no shares' do
      it 'returns an empty array' do
        get '/api/v1/shares', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data']).to be_empty
      end
    end
  end

  describe 'POST /api/v1/lists/:list_id/shares' do
    let!(:list) { create(:list, organization: organization, creator: user) }
    let!(:target_orgs) { create_list(:organization, 2) }
    let(:valid_params) do
      {
        target_organization_ids: target_orgs.map(&:id),
        share: {
          permission: 'view',
          reshareable: true
        }
      }
    end

    context 'when user belongs to the list\'s organization' do
      it 'creates shares for all target organizations' do
        expect {
          post "/api/v1/lists/#{list.id}/shares",
               params: valid_params.to_json,
               headers: @auth_headers.merge('Content-Type' => 'application/json')
        }.to change(Share, :count).by(2)

        expect(response).to have_http_status(:created)
        expect(json_response['data'].length).to eq(2)
      end
    end

    context 'when user has edit permission and reshareable' do
      let!(:other_org) { create(:organization) }
      let!(:list) { create(:list, organization: other_org, creator: create(:user)) }
      let!(:existing_share) do
        create(:share,
               source_organization: other_org,
               target_organization: organization,
               shareable: list,
               creator: create(:user),
               permission: :edit,
               reshareable: true,
               status: :accepted)
      end

      it 'allows creating new shares' do
        expect {
          post "/api/v1/lists/#{list.id}/shares",
               params: valid_params.to_json,
               headers: @auth_headers.merge('Content-Type' => 'application/json')
        }.to change(Share, :count).by(2)

        expect(response).to have_http_status(:created)
      end
    end

    context 'when user does not have permission' do
      let!(:other_org) { create(:organization) }
      let!(:list) { create(:list, organization: other_org, creator: create(:user)) }

      it 'returns unauthorized' do
        post "/api/v1/lists/#{list.id}/shares",
             params: valid_params.to_json,
             headers: @auth_headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/shares/:id/accept' do
    let!(:other_org) { create(:organization) }
    let!(:list) { create(:list, organization: other_org, creator: create(:user)) }
    let!(:share) { create(:share, source_organization: other_org, target_organization: organization, shareable: list, status: :pending) }

    context 'when organization is the target' do
      it 'accepts the share' do
        post "/api/v1/shares/#{share.id}/accept", headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(share.reload.status).to eq('accepted')
      end
    end

    context 'when organization is not the target' do
      let!(:share) { create(:share, source_organization: organization, target_organization: target_org, shareable: create(:list, organization: organization, creator: user)) }

      it 'returns unauthorized' do
        post "/api/v1/shares/#{share.id}/accept", headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/shares/:id/decline' do
    let!(:other_org) { create(:organization) }
    let!(:list) { create(:list, organization: other_org, creator: create(:user)) }
    let!(:share) { create(:share, source_organization: other_org, target_organization: organization, shareable: list, status: :pending) }

    context 'when organization is the target' do
      it 'declines the share' do
        post "/api/v1/shares/#{share.id}/decline", headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(share.reload.status).to eq('rejected')
      end
    end

    context 'when organization is not the target' do
      let!(:share) { create(:share, source_organization: organization, target_organization: target_org, shareable: create(:list, organization: organization, creator: user)) }

      it 'returns unauthorized' do
        post "/api/v1/shares/#{share.id}/decline", headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/shares/accept_all' do
    let!(:other_org) { create(:organization) }
    let!(:list1) { create(:list, organization: other_org, creator: create(:user)) }
    let!(:list2) { create(:list, organization: other_org, creator: create(:user)) }

    context 'when organization has pending shares' do
      let!(:share1) { create(:share, source_organization: other_org, target_organization: organization, shareable: list1, status: :pending) }
      let!(:share2) { create(:share, source_organization: other_org, target_organization: organization, shareable: list2, status: :pending) }
      let!(:accepted_share) { create(:share, source_organization: other_org, target_organization: organization, shareable: create(:list), status: :accepted) }

      it 'accepts all pending shares' do
        post '/api/v1/shares/accept_all', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(2)
        expect(share1.reload.status).to eq('accepted')
        expect(share2.reload.status).to eq('accepted')
        expect(accepted_share.reload.status).to eq('accepted')
      end
    end

    context 'when organization has no pending shares' do
      it 'returns success with message' do
        post '/api/v1/shares/accept_all', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('No pending shares to accept')
      end
    end
  end

  describe 'POST /api/v1/shares/decline_all' do
    let!(:other_org) { create(:organization) }
    let!(:list1) { create(:list, organization: other_org, creator: create(:user)) }
    let!(:list2) { create(:list, organization: other_org, creator: create(:user)) }

    context 'when organization has pending shares' do
      let!(:share1) { create(:share, source_organization: other_org, target_organization: organization, shareable: list1, status: :pending) }
      let!(:share2) { create(:share, source_organization: other_org, target_organization: organization, shareable: list2, status: :pending) }
      let!(:accepted_share) { create(:share, source_organization: other_org, target_organization: organization, shareable: create(:list), status: :accepted) }

      it 'declines all pending shares' do
        post '/api/v1/shares/decline_all', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['data'].length).to eq(2)
        expect(share1.reload.status).to eq('rejected')
        expect(share2.reload.status).to eq('rejected')
        expect(accepted_share.reload.status).to eq('accepted')
      end
    end

    context 'when organization has no pending shares' do
      it 'returns success with message' do
        post '/api/v1/shares/decline_all', headers: @auth_headers
        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('No pending shares to decline')
      end
    end
  end

  describe 'DELETE /api/v1/shares/:id' do
    let!(:other_org) { create(:organization) }
    let!(:list) { create(:list, organization: other_org, creator: create(:user)) }

    context 'when organization is the target' do
      let!(:share) { create(:share, source_organization: other_org, target_organization: organization, shareable: list) }

      it 'deletes the share' do
        expect {
          delete "/api/v1/shares/#{share.id}", headers: @auth_headers
        }.to change(Share, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when organization is the source' do
      let!(:share) { create(:share, source_organization: organization, target_organization: other_org, shareable: create(:list, organization: organization, creator: user)) }

      it 'deletes the share' do
        expect {
          delete "/api/v1/shares/#{share.id}", headers: @auth_headers
        }.to change(Share, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is the creator' do
      let!(:share) { create(:share, creator: user, source_organization: other_org, target_organization: create(:organization), shareable: list) }

      it 'deletes the share' do
        expect {
          delete "/api/v1/shares/#{share.id}", headers: @auth_headers
        }.to change(Share, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when neither creator nor source/target organization' do
      let!(:share) { create(:share, source_organization: other_org, target_organization: create(:organization), shareable: list) }

      it 'returns unauthorized' do
        delete "/api/v1/shares/#{share.id}", headers: @auth_headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
