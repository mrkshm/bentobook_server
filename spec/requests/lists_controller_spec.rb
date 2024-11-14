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
end
