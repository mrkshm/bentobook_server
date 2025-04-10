require 'rails_helper'

RSpec.describe ListsController, type: :controller do
  # Setup shared resources
  before(:all) do
    @shared_organization = create(:organization)
    @shared_user = create(:user)
    create(:membership, user: @shared_user, organization: @shared_organization)
  end

  after(:all) do
    # Clean up shared resources
    @shared_user.destroy  # Destroy user first since it has the membership
    @shared_organization.destroy
  end

  let(:list) { create(:list, creator: @shared_user, organization: @shared_organization) }

  # Helper method to debug request issues
  def debug_request
    puts "\n=== Test Debug ==="
    puts "Current.organization: #{Current.organization.inspect}"
    puts "Current.user: #{Current.user.inspect}"
    puts "=== End Debug ==="
  end

  describe 'authentication' do
    it 'redirects to sign in page when not authenticated' do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'when authenticated' do
    before(:each) do
      sign_in @shared_user
      Current.user = @shared_user
      Current.organization = @shared_organization
    end

    after(:each) do
      Current.organization = nil
      Current.user = nil
    end

    describe 'GET #index' do
      it 'returns successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns @lists' do
        list1 = create(:list, creator: @shared_user, organization: @shared_organization, name: 'First List')
        list2 = create(:list, creator: @shared_user, organization: @shared_organization, name: 'Second List')

        get :index
        expect(assigns(:lists)).to include(list1, list2)
      end
    end

    describe 'GET #show' do
      it 'assigns the requested list as @list' do
        get :show, params: { id: list.to_param }
        expect(assigns(:list)).to eq(list)
      end

      it 'assigns restaurants in the list as @restaurants' do
        restaurant1 = create(:restaurant, organization: @shared_organization, name: 'Sushi Place')
        restaurant2 = create(:restaurant, organization: @shared_organization, name: 'BBQ Joint')
        list.restaurants << [ restaurant1, restaurant2 ]

        get :show, params: { id: list.to_param, order_by: 'name', order_direction: 'desc' }
        expect(assigns(:restaurants)).to include(restaurant1, restaurant2)
      end
    end

    describe 'POST #create' do
      context 'with valid parameters' do
        it 'creates a new list' do
          expect {
            post :create, params: { list: { name: 'New List', description: 'Test description' } }
          }.to change(List, :count).by(1)

          list = List.last
          expect(list.organization).to eq(@shared_organization)
          expect(list.creator).to eq(@shared_user)
          expect(response).to redirect_to(list_path(id: list.id))
          expect(flash[:notice]).to be_present
        end
      end

      context 'with invalid parameters' do
        it 'does not create a list' do
          expect {
            post :create, params: { list: { name: '' } }
          }.not_to change(List, :count)

          expect(assigns(:list)).to be_a_new(List)
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'PATCH #update' do
      it 'updates the list' do
        patch :update, params: { id: list.to_param, list: { name: 'Updated Name' } }
        expect(list.reload.name).to eq('Updated Name')
        expect(response).to redirect_to(list_path(id: list.id))
      end

      it 'handles invalid updates' do
        patch :update, params: { id: list.to_param, list: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the list' do
        list_to_delete = create(:list, creator: @shared_user, organization: @shared_organization)

        expect {
          delete :destroy, params: { id: list_to_delete.id }
        }.to change(List, :count).by(-1)

        expect(response).to redirect_to(lists_path)
      end
    end

    describe 'GET #export' do
      it 'with markdown format returns markdown file' do
        get :export, params: { id: list.id, format: :text }
        expect(response.headers['Content-Type']).to include('text/markdown')
        expect(response.headers['Content-Disposition']).to include('attachment')
      end

      it 'with html format renders export modal without email' do
        get :export, params: { id: list.id, format: :html }
        expect(response).to render_template('lists/export_modal')
      end

      it 'with html format redirects with success message when email provided' do
        get :export, params: { id: list.id, format: :html, email: 'test@example.com' }
        expect(response).to redirect_to(list_path(id: list.id, locale: nil))
        expect(flash[:success]).to be_present
      end

      it 'with turbo_stream format sends email and renders turbo stream response' do
        get :export, params: { id: list.id, format: :turbo_stream, email: 'test@example.com' }
        expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      end
    end

    describe 'visibility management' do
      it 'creates a personal list' do
        post :create, params: { list: { name: 'Personal List', visibility: 'personal' } }
        expect(List.last.visibility).to eq('personal')
      end

      it 'creates a discoverable list' do
        post :create, params: { list: { name: 'Discoverable List', visibility: 'discoverable' } }
        expect(List.last.visibility).to eq('discoverable')
      end

      it 'updates list visibility' do
        list = create(:list, :personal, creator: @shared_user, organization: @shared_organization)
        patch :update, params: { id: list.id, list: { visibility: 'discoverable' } }
        expect(list.reload).to be_discoverable
      end
    end
  end

  context 'with shared lists' do
    let(:owner_organization) { create(:organization) }
    let(:owner_user) { create(:user) }
    let(:owner_membership) { create(:membership, user: owner_user, organization: owner_organization) }
    let(:shared_list) { create(:list, creator: owner_user, organization: owner_organization) }

    before(:each) do
      owner_membership # ensure membership exists
      sign_in @shared_user
      Current.user = @shared_user
      Current.organization = @shared_organization
    end

    after(:each) do
      Current.organization = nil
      Current.user = nil
    end

    describe 'GET #show' do
      context 'when authenticated as viewer' do
        before do
          # Create a share with view permission
          owner_organization.share_list(shared_list, @shared_organization, permission: 'view', creator: owner_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: @shared_organization.id)
          @shared_organization.accept_share(share)
        end

        it 'allows viewing' do
          get :show, params: { id: shared_list.id }
          expect(response).to be_successful
          expect(assigns(:list)).to eq(shared_list)
        end

        it 'includes visit statistics' do
          get :show, params: { id: shared_list.id }
          expect(assigns(:statistics)).to be_present
        end
      end

      context 'when authenticated as editor' do
        before do
          # Create a share with edit permission
          owner_organization.share_list(shared_list, @shared_organization, permission: 'edit', creator: owner_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: @shared_organization.id)
          @shared_organization.accept_share(share)
        end

        it 'allows viewing' do
          get :show, params: { id: shared_list.id }
          expect(response).to be_successful
          expect(assigns(:list)).to eq(shared_list)
        end
      end
    end

    describe 'PATCH #update' do
      context 'when user has view permission' do
        before do
          # Create a share with view permission
          owner_organization.share_list(shared_list, @shared_organization, permission: 'view', creator: owner_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: @shared_organization.id)
          @shared_organization.accept_share(share)
        end

        it 'prevents editing' do
          patch :update, params: { id: shared_list.id, list: { name: 'Updated Name' } }
          expect(response).to redirect_to(list_path(id: shared_list.id, locale: nil))
          expect(flash[:alert]).to be_present
          expect(shared_list.reload.name).not_to eq('Updated Name')
        end
      end

      context 'when user has edit permission' do
        before do
          # Create a share with edit permission
          owner_organization.share_list(shared_list, @shared_organization, permission: 'edit', creator: owner_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: @shared_organization.id)
          @shared_organization.accept_share(share)
        end

        it 'allows editing' do
          patch :update, params: { id: shared_list.id, list: { name: 'Updated Name' } }
          expect(response).to redirect_to(list_path(id: shared_list.id, locale: nil))
          expect(shared_list.reload.name).to eq('Updated Name')
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'when authenticated as viewer' do
        before do
          # Create a share with view permission
          owner_organization.share_list(shared_list, @shared_organization, permission: 'view', creator: owner_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: @shared_organization.id)
          @shared_organization.accept_share(share)
        end

        it 'prevents deletion' do
          expect {
            delete :destroy, params: { id: shared_list.id }
          }.not_to change(List, :count)

          expect(response).to redirect_to(list_path(id: shared_list.id, locale: nil))
          expect(flash[:alert]).to be_present
        end
      end

      context 'when authenticated as editor' do
        before do
          # Create a share with edit permission
          owner_organization.share_list(shared_list, @shared_organization, permission: 'edit', creator: owner_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: @shared_organization.id)
          @shared_organization.accept_share(share)
        end

        it 'prevents deletion' do
          expect {
            delete :destroy, params: { id: shared_list.id }
          }.not_to change(List, :count)

          expect(response).to redirect_to(list_path(id: shared_list.id, locale: nil))
          expect(flash[:alert]).to be_present
        end
      end

      context 'when authenticated as creator' do
        before do
          sign_in owner_user
          Current.user = owner_user
          Current.organization = owner_organization
        end

        it 'allows deletion' do
          list_to_delete = create(:list, creator: owner_user, organization: owner_organization)

          # Add debug information
          puts "CREATOR DELETE TEST DEBUG:"
          puts "List ID: #{list_to_delete.id}"
          puts "List creator_id: #{list_to_delete.creator_id}"
          puts "Current user ID: #{owner_user.id}"
          puts "List organization_id: #{list_to_delete.organization_id}"
          puts "Current organization ID: #{owner_organization.id}"

          expect {
            delete :destroy, params: { id: list_to_delete.id }
          }.to change(List, :count).by(-1)

          expect(response).to redirect_to(lists_path(locale: nil))
        end
      end
    end
  end

  describe 'sharing functionality' do
    let(:recipient_organization) { create(:organization) }
    let(:recipient_user) { create(:user) }
    let(:recipient_membership) { create(:membership, user: recipient_user, organization: recipient_organization) }

    before(:each) do
      recipient_membership # ensure membership exists
      sign_in @shared_user
      Current.user = @shared_user
      Current.organization = @shared_organization
    end

    describe 'GET #share' do
      it 'when authenticated as creator renders share modal' do
        get :share, params: { id: list.id }
        expect(response).to render_template('lists/_share_modal')
        expect(assigns(:list)).to eq(list)
      end
    end

    describe 'DELETE #remove_share' do
      context 'when authenticated as recipient' do
        let(:shared_list) { create(:list, creator: @shared_user, organization: @shared_organization) }

        before do
          # Create a share from shared_user to recipient_user
          @shared_organization.share_list(shared_list, recipient_organization, permission: 'view', creator: @shared_user)
          share = Share.find_by(shareable: shared_list, target_organization_id: recipient_organization.id)
          recipient_organization.accept_share(share)

          # Sign in as recipient
          sign_in recipient_user
          Current.user = recipient_user
          Current.organization = recipient_organization
        end

        it 'removes share with html format' do
          expect {
            delete :remove_share, params: { id: shared_list.id, format: :html }
          }.to change { recipient_organization.reload.shared_lists.count }.by(-1)

          expect(response).to redirect_to(lists_path(locale: nil))
        end

        it 'removes share with html format only' do
          expect {
            delete :remove_share, params: { id: shared_list.id }
          }.to change { recipient_organization.reload.shared_lists.count }.by(-1)

          expect(response).to redirect_to(lists_path(locale: nil))
        end
      end
    end

    describe 'POST #accept_share' do
      context 'when authenticated as recipient' do
        let(:shared_list) { create(:list, creator: @shared_user, organization: @shared_organization) }

        before do
          # Create a pending share
          @shared_organization.share_list(shared_list, recipient_organization, permission: 'view', creator: @shared_user)

          # Sign in as recipient
          sign_in recipient_user
          Current.user = recipient_user
          Current.organization = recipient_organization
        end

        it 'accepts share with html format' do
          expect {
            post :accept_share, params: { id: shared_list.id, format: :html }
          }.to change { recipient_organization.reload.shared_lists.count }.by(1)

          expect(response).to redirect_to(lists_path(locale: nil))
        end

        it 'accepts share with turbo_stream format' do
          expect {
            post :accept_share, params: { id: shared_list.id, format: :turbo_stream }
          }.to change { recipient_organization.reload.shared_lists.count }.by(1)

          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end
    end

    describe 'DELETE #decline_share' do
      context 'when authenticated as recipient' do
        let(:shared_list) { create(:list, creator: @shared_user, organization: @shared_organization) }

        before do
          # Create a pending share
          @shared_organization.share_list(shared_list, recipient_organization, permission: 'view', creator: @shared_user)

          # Sign in as recipient
          sign_in recipient_user
          Current.user = recipient_user
          Current.organization = recipient_organization
        end

        it 'declines share with html format' do
          expect {
            delete :decline_share, params: { id: shared_list.id, format: :html }
          }.to change { recipient_organization.reload.incoming_shares.pending.count }.by(-1)

          expect(response).to redirect_to(lists_path(locale: nil))
        end

        it 'declines share with turbo_stream format' do
          expect {
            delete :decline_share, params: { id: shared_list.id, format: :turbo_stream }
          }.to change { recipient_organization.reload.incoming_shares.pending.count }.by(-1)

          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end
    end
  end
end
