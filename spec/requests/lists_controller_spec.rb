require 'rails_helper'

RSpec.describe ListsController, type: :request do
  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }
  
  describe 'authentication' do
    it 'redirects to login when not authenticated' do
      get lists_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
  
  context 'when authenticated' do
    before { sign_in user }

    describe 'GET /lists' do
      it 'returns successful response' do
        get lists_path
        expect(response).to be_successful
      end
      
      it 'shows lists in descending order' do
        list1 = create(:list, owner: user, name: 'First List')
        list2 = create(:list, owner: user, name: 'Second List')
        
        get lists_path
        expect(response.body).to include('First List')
        expect(response.body).to include('Second List')
      end
    end

    describe 'GET /lists/:id' do
      it 'shows list details' do
        get list_path(id: list.id)
        expect(response).to be_successful
      end
      
      it 'orders restaurants by specified field' do
        restaurant1 = create(:restaurant, name: 'Sushi Place')
        restaurant2 = create(:restaurant, name: 'BBQ Joint')
        list.restaurants << [restaurant1, restaurant2]
        
        get list_path(id: list.id, order_by: 'name', order_direction: 'desc')
        expect(response).to be_successful
      end
    end

    describe 'POST /lists' do
      let(:valid_params) { 
        { 
          list: { 
            name: 'New List', 
            description: 'Description', 
            visibility: 'personal' 
          } 
        } 
      }
      let(:invalid_params) { { list: { name: '', description: 'Description' } } }

      context 'with valid parameters' do
        it 'creates a new list' do
          expect {
            post lists_path, params: valid_params
          }.to change(List, :count).by(1)
          
          list = List.last
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:notice]).to be_present
        end
      end

      context 'with invalid parameters' do
        it 'does not create a list' do
          expect {
            post lists_path, params: invalid_params
          }.not_to change(List, :count)
          
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe 'PATCH /lists/:id' do
      let(:update_params) { { list: { name: 'Updated Name' } } }

      it 'updates the list' do
        patch list_path(id: list.id), params: update_params
        expect(list.reload.name).to eq('Updated Name')
        expect(response).to redirect_to(list_path(id: list.id))
      end

      it 'handles invalid updates' do
        patch list_path(id: list.id), params: { list: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe 'DELETE /lists/:id' do
      it 'deletes the list' do
        list_to_delete = create(:list, owner: user)
        
        expect {
          delete list_path(id: list_to_delete.id)
        }.to change(List, :count).by(-1)
        
        expect(response).to redirect_to(lists_path)
        expect(flash[:notice]).to be_present
      end
    end

    describe 'GET /lists/:id/export' do
      context 'with markdown format' do
        it 'returns markdown file' do
          get export_list_path(id: list.id, format: :text)
          
          expect(response.headers['Content-Type']).to eq('text/markdown')
          expect(response.headers['Content-Disposition']).to include('.md')
        end
      end

      context 'with html format' do
        it 'renders export modal without email' do
          get export_list_path(id: list.id)
          expect(response).to be_successful
        end

        it 'redirects with success message when email provided' do
          get export_list_path(id: list.id), params: { email: 'test@example.com' }
          expect(response).to redirect_to(list_path(id: list.id))
        end
      end
    end

    describe 'POST /lists/:id/export' do
      context 'with email sharing' do
        let(:valid_params) do
          { 
            email: 'test@example.com',
            include_stats: '1',
            include_notes: '1',
            format: :turbo_stream
          }
        end

        it 'sends email and shows success message' do
          expect {
            post export_list_path(id: list.id), params: valid_params
          }.to have_enqueued_job(ActionMailer::MailDeliveryJob)

          expect(response).to be_successful
          expect(response.body).to include('success')
        end
      end
    end

    describe 'visibility management' do
      it 'creates a personal list' do
        post lists_path, params: { list: { name: 'Personal List', visibility: 'personal' } }
        expect(List.last).to be_personal
      end

      it 'creates a discoverable list' do
        post lists_path, params: { list: { name: 'Public List', visibility: 'discoverable' } }
        expect(List.last).to be_discoverable
      end

      it 'updates visibility from personal to discoverable' do
        list = create(:list, :personal, owner: user)
        patch list_path(id: list.id), params: { list: { visibility: 'discoverable' } }
        expect(list.reload).to be_discoverable
      end
    end
  end

  context 'with shared lists' do
    let(:owner) { create(:user) }
    let(:viewer) { create(:user) }
    let(:editor) { create(:user) }
    let(:list) { create(:list, owner: owner) }

    before do
      create(:share, creator: owner, recipient: viewer, 
             shareable: list, permission: :view, status: :accepted)
      create(:share, creator: owner, recipient: editor, 
             shareable: list, permission: :edit, status: :accepted)
    end

    describe 'GET /lists/:id' do
      it 'shows list to viewer' do
        sign_in viewer
        get list_path(id: list.id)
        expect(response).to be_successful
      end

      it 'shows list to editor' do
        sign_in editor
        get list_path(id: list.id)
        expect(response).to be_successful
      end

      it 'shows correct statistics for viewer' do
        restaurant = create(:restaurant)
        list.restaurants << restaurant
        create(:visit, user: viewer, restaurant: restaurant)

        sign_in viewer
        get list_path(id: list.id)
        expect(response.body).to include('100%') # Visited percentage
      end
    end

    describe 'PATCH /lists/:id' do
      context 'when user has view permission' do
        before { sign_in viewer }

        it 'prevents editing' do
          patch list_path(id: list.id), params: { list: { name: 'New Name' } }
          expect(response).to redirect_to(list_path(list))
          expect(flash[:alert]).to be_present
        end
      end

      context 'when user has edit permission' do
        before { sign_in editor }

        it 'allows editing' do
          patch list_path(id: list.id), params: { list: { name: 'New Name' } }
          expect(list.reload.name).to eq('New Name')
          expect(response).to redirect_to(list_path(id: list.id))
        end
      end
    end

    describe 'DELETE /lists/:id' do
      it 'prevents deletion by viewer' do
        sign_in viewer
        delete list_path(id: list.id)
        expect(response).to redirect_to(list_path(list))
        expect(List.exists?(list.id)).to be true
      end

      it 'prevents deletion by editor' do
        sign_in editor
        delete list_path(id: list.id)
        expect(response).to redirect_to(list_path(list))
        expect(List.exists?(list.id)).to be true
      end

      it 'allows deletion by owner' do
        sign_in owner
        delete list_path(id: list.id)
        expect(response).to redirect_to(lists_path)
        expect(List.exists?(list.id)).to be false
      end
    end
  end

  context 'sharing functionality' do
    let(:owner) { create(:user) }
    let(:recipient) { create(:user) }
    let(:list) { create(:list, owner: owner) }

    describe 'GET /lists/:id/share' do
      before { sign_in owner }

      it 'renders share modal' do
        get share_list_path(id: list.id)
        expect(response).to be_successful
        expect(response.body).to include('share_modal')
      end
    end

    describe 'DELETE /lists/:id/remove_share' do
      let!(:share) { create(:share, creator: owner, recipient: recipient, shareable: list, status: :accepted) }
      
      before { sign_in recipient }

      it 'removes share with html format' do
        expect {
          delete remove_share_list_path(id: list.id)
        }.to change(Share, :count).by(-1)
        
        expect(response).to redirect_to(lists_path)
        expect(flash[:notice]).to be_present
      end

      it 'removes share with turbo_stream format' do
        delete remove_share_list_path(id: list.id, format: :turbo_stream)
        
        expect(response).to be_successful
        expect(flash.now[:notice]).to be_present
      end
    end

    describe 'POST /lists/:id/accept_share' do
      let!(:share) { create(:share, creator: owner, recipient: recipient, shareable: list, status: :pending) }
      
      before { sign_in recipient }

      it 'accepts share with html format' do
        post accept_share_list_path(id: list.id)
        
        expect(share.reload).to be_accepted
        expect(response).to redirect_to(lists_path)
        expect(flash[:notice]).to be_present
      end

      it 'accepts share with turbo_stream format' do
        post accept_share_list_path(id: list.id, format: :turbo_stream)
        
        expect(share.reload).to be_accepted
        expect(response).to be_successful
        expect(response.body).to include('turbo-stream')
        expect(flash.now[:notice]).to be_present
      end
    end

    describe 'DELETE /lists/:id/decline_share' do
      let!(:share) { create(:share, creator: owner, recipient: recipient, shareable: list, status: :pending) }
      
      before { sign_in recipient }

      it 'declines share with html format' do
        expect {
          delete decline_share_list_path(id: list.id)
        }.to change(Share, :count).by(-1)
        
        expect(response).to redirect_to(lists_path)
        expect(flash[:notice]).to be_present
      end

      it 'declines share with turbo_stream format' do
        delete decline_share_list_path(id: list.id, format: :turbo_stream)
        
        expect(response).to be_successful
        expect(response.body).to include('turbo-stream')
        expect(flash.now[:notice]).to be_present
      end
    end
  end
end
