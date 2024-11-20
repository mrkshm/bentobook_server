require 'rails_helper'

RSpec.describe SharesController, type: :request do
  let(:user) { create(:user) }
  let(:recipient) { create(:user) }
  let(:list) { create(:list, owner: user) }
  
  describe 'POST /shares' do
    let(:valid_params) do
      {
        share: {
          recipient_id: recipient.id,
          permission: 'view',
          reshareable: true
        },
        recipient_ids: [recipient.id],
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
        expect(share.recipient).to eq(recipient)
        expect(share.shareable).to eq(list)
        expect(share.permission).to eq('view')
        expect(share.reshareable).to be true
        expect(share).to be_pending
      end
      
      it 'creates multiple shares for multiple recipients' do
        recipient2 = create(:user)
        params = valid_params.merge(recipient_ids: [recipient.id, recipient2.id])

        expect {
          post shares_path, params: params
        }.to change(Share, :count).by(2)
      end
      
      context 'with invalid params' do
        it 'handles missing recipient' do
          post shares_path, params: valid_params.merge(recipient_ids: [])
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to be_present
        end
        
        it 'handles invalid recipient ids' do
          post shares_path, params: valid_params.merge(recipient_ids: ['invalid'])
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to be_present
        end
        
        it 'prevents sharing with self' do
          params = valid_params.merge(recipient_ids: [user.id])
          
          post shares_path, params: params
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to include("can't be the same as creator")
        end
      end
      
      it 'sends share notifications' do
        expect {
          post shares_path, params: valid_params
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
    
    context 'when not authenticated' do
      it 'returns unauthorized status' do
        post shares_path, params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include('You need to sign in or sign up before continuing')
      end
    end
  end

  describe 'PATCH /shares/:id/accept' do
    let(:share) { create(:share, :pending, recipient: recipient, creator: user, shareable: list) }

    context 'when authenticated as recipient' do
      before { sign_in recipient }

      it 'accepts the share' do
        patch accept_share_path(id: share.id)
        expect(share.reload).to be_accepted
        expect(response).to redirect_to(lists_path)
      end
    end

    context 'when authenticated as non-recipient' do
      before { sign_in user }

      it 'does not accept the share' do
        patch accept_share_path(id: share.id)
        expect(share.reload).to be_pending
        expect(response).to redirect_to(lists_path)
      end
    end
  end

  describe 'PATCH /shares/:id/decline' do
    let(:share) { create(:share, recipient: recipient, creator: user, shareable: list) }

    context 'when authenticated as recipient' do
      before { sign_in recipient }

      it 'declines the share' do
        patch decline_share_path(id: share.id)
        expect(share.reload).to be_rejected
        expect(response).to redirect_to(lists_path)
      end
    end
  end
end
