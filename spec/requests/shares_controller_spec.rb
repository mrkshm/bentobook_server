require 'rails_helper'

RSpec.describe SharesController, type: :request do
  let(:user) { create(:user) }
  let(:recipient) { create(:user) }
  let(:list) { create(:list, :restricted, owner: user) }
  
  describe 'POST /shares' do
    let(:valid_params) do
      {
        share: {
          recipient_id: recipient.id,
          permission: 'view'
        },
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
        expect(share).to be_pending
      end
      
      context 'with invalid params' do
        it 'handles missing recipient' do
          post shares_path, params: valid_params.deep_merge(
            share: { recipient_id: nil }
          )
          
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:alert]).to be_present
        end
        
        it 'prevents sharing personal lists' do
          personal_list = create(:list, :personal, owner: user)
          
          post shares_path, params: valid_params.deep_merge(
            shareable_id: personal_list.id
          )
          
          expect(response).to redirect_to(list_path(id: personal_list.id))
          expect(flash[:alert]).to include("Cannot share a personal list")
        end
      end
    end
    
    context 'when not authenticated' do
      it 'redirects to login' do
        post shares_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
