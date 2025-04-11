require 'rails_helper'

RSpec.describe SharesController, type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:target_organization) { create(:organization) }
  let(:list) { create(:list, organization: organization, creator: user) }
  
  before do
    create(:membership, user: user, organization: organization)
    # Set Current.organization for the test
    allow(Current).to receive(:organization).and_return(organization)
  end
  
  describe 'POST /shares' do
    let(:valid_params) do
      {
        share: {
          permission: 'view',
          reshareable: true
        },
        target_organization_ids: [target_organization.id],
        shareable_type: 'List',
        shareable_id: list.id
      }
    end
    
    context 'when authenticated' do
      before { sign_in user }
      
      it 'creates a new share' do
        expect {
          post shares_path, params: valid_params
        }.to change(Share, :count).by(1)
        
        expect(response).to redirect_to(list_path(id: list.id))
        expect(flash[:notice]).to be_present
      end
      
      it 'sets the correct attributes' do
        post shares_path, params: valid_params
        
        share = Share.last
        expect(share.creator).to eq(user)
        expect(share.source_organization).to eq(organization)
        expect(share.target_organization).to eq(target_organization)
        expect(share.shareable).to eq(list)
        expect(share.permission).to eq('view')
        expect(share.reshareable).to be true
        expect(share).to be_pending
      end
      
      it 'creates multiple shares for multiple target organizations' do
        another_organization = create(:organization)
        params = valid_params.merge(target_organization_ids: [target_organization.id, another_organization.id])

        expect {
          post shares_path, params: params
        }.to change(Share, :count).by(2)
      end
      
      context 'with invalid params' do
        it 'handles missing target organization' do
          post shares_path, params: valid_params.merge(target_organization_ids: [])
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to be_present
        end
        
        it 'handles invalid target organization ids' do
          post shares_path, params: valid_params.merge(target_organization_ids: ['invalid'])
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to be_present
        end
        
        it 'prevents sharing with own organization' do
          params = valid_params.merge(target_organization_ids: [organization.id])
          
          post shares_path, params: params
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to include("Target organization can't be the same as source organization")
        end
      end
      
      it 'sends share notifications' do
        expect {
          post shares_path, params: valid_params
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to sign in page' do
        post shares_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /shares/:id/accept' do
    let(:share) { create(:share, :pending, source_organization: organization, target_organization: target_organization, creator: user, shareable: list) }
    let(:target_user) { create(:user) }

    before do
      create(:membership, user: target_user, organization: target_organization)
    end

    context 'when authenticated as member of target organization' do
      before do 
        sign_in target_user
        allow(Current).to receive(:organization).and_return(target_organization)
      end

      it 'accepts the share' do
        patch accept_share_path(id: share.id)
        expect(share.reload).to be_accepted
        expect(response).to redirect_to(lists_path)
      end
    end

    context 'when authenticated as non-member of target organization' do
      before { sign_in user }

      it 'does not accept the share' do
        patch accept_share_path(id: share.id)
        expect(share.reload).to be_pending
        expect(response).to redirect_to(lists_path)
      end
    end
  end

  describe 'PATCH /shares/:id/decline' do
    let(:share) { create(:share, source_organization: organization, target_organization: target_organization, creator: user, shareable: list) }
    let(:target_user) { create(:user) }

    before do
      create(:membership, user: target_user, organization: target_organization)
    end

    context 'when authenticated as member of target organization' do
      before do
        sign_in target_user
        allow(Current).to receive(:organization).and_return(target_organization)
      end

      it 'declines the share' do
        patch decline_share_path(id: share.id)
        expect(share.reload).to be_rejected
        expect(response).to redirect_to(lists_path)
      end
    end
  end
end
