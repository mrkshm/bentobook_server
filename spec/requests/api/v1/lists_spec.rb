require 'rails_helper'

RSpec.describe 'Api::V1::Lists', type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:membership) { create(:membership, user: user, organization: organization) }
  let(:headers) { sign_in_with_token(user) }
  let(:other_user) { create(:user) }
  let(:other_organization) { create(:organization) }
  let(:other_membership) { create(:membership, user: other_user, organization: other_organization) }

  before do
    membership # ensure membership is created
    other_membership # ensure other membership is created
    @headers = headers
    set_current_organization(organization)
    Rails.logger.info "Test setup: Headers after sign_in: #{@headers.inspect}"
  end

  after do
    # Reset Current.organization to avoid affecting other tests
    allow(Current).to receive(:organization).and_call_original
    allow(Current).to receive(:user).and_call_original
  end

  # Helper to reset json_response between requests
  def reset_json_response
    @json_response = nil
  end

  # Helper to set Current.organization and ensure it persists during requests
  def set_current_organization(org)
    Current.organization = org
    allow(Current).to receive(:organization).and_return(org)
  end

  # Helper to add debug output
  def debug_request(path, params = nil)
    Rails.logger.info "\n=== DEBUG: Request to #{path} ===" 
    Rails.logger.info "Headers: #{@headers.inspect}"
    Rails.logger.info "Current.organization: #{Current.organization.inspect}"
    Rails.logger.info "Params: #{params.inspect}" if params
  end

  describe 'GET /api/v1/lists' do
    context 'when organization has lists' do
      before do
        create_list(:list, 2, organization: organization, creator: user)
        create(:list, organization: other_organization, creator: other_user) # another organization's list
      end

      it 'returns only organization owned lists by default' do
        debug_request('/api/v1/lists')
        get '/api/v1/lists', headers: @headers
        Rails.logger.info "Response status: #{response.status}"
        Rails.logger.info "Response body: #{response.body}"

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(data['status']).to eq('success')
        expect(data['data']).to be_an(Array)
        expect(data['data'].length).to eq(2)

        list_data = data['data'].first
        expect(list_data['type']).to eq('list')
        expect(list_data['attributes']).to include(
          'name',
          'description',
          'visibility',
          'premium',
          'position',
          'created_at',
          'updated_at',
          'restaurant_count'
        )

        expect(data['meta']).to include(
          'timestamp',
          'pagination'
        )
        expect(data['meta']['pagination']).to include(
          'current_page',
          'total_pages',
          'total_count'
        )
      end

      context 'with pagination' do
        before do
          # Clear existing lists
          List.destroy_all
          # Create 7 lists to test pagination
          create_list(:list, 7, organization: organization, creator: user)
        end

        it 'respects per_page parameter' do
          get '/api/v1/lists?per_page=3', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(3)
          expect(data['meta']['pagination']).to include(
            'current_page' => 1,
            'total_pages' => 3,
            'total_count' => 7
          )
        end

        it 'returns the correct page' do
          get '/api/v1/lists?per_page=3&page=2', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(3)
          expect(data['meta']['pagination']).to include(
            'current_page' => 2,
            'total_pages' => 3,
            'total_count' => 7
          )
        end

        it 'returns remaining items on last page' do
          get '/api/v1/lists?per_page=3&page=3', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(1) # Only 1 item on last page
          expect(data['meta']['pagination']).to include(
            'current_page' => 3,
            'total_pages' => 3,
            'total_count' => 7
          )
        end

        it 'handles page overflow gracefully' do
          get '/api/v1/lists?per_page=3&page=10', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['meta']['pagination']).to include(
            'current_page' => 3, # Should return last page
            'total_pages' => 3,
            'total_count' => 7
          )
        end
      end

      context 'when include=shared' do
        before do
          # Clear existing lists
          List.destroy_all
          
          # Create a list owned by the user's organization
          @owned_list = create(:list, organization: organization, creator: user, name: 'My List')
          
          # Create a list in another organization that's shared with the user's organization
          @shared_list = create(:list, organization: other_organization, creator: other_user, name: 'Shared List')
          @share = create(:share, 
                         creator: other_user, 
                         source_organization: other_organization,
                         target_organization: organization, 
                         shareable: @shared_list, 
                         status: :accepted)
          
          # Debug the setup
          puts "\n=== DEBUG: Shared Lists Setup ==="
          puts "Owned list: #{@owned_list.inspect}"
          puts "Shared list: #{@shared_list.inspect}"
          puts "Share: #{@share.inspect}"
          puts "User: #{user.inspect}"
          puts "User's organizations: #{user.organizations.pluck(:id, :name)}"
          puts "Current.organization: #{Current.organization.inspect}"
          
          # Let's check what lists are accessible to the user
          puts "\n=== DEBUG: Lists accessible to user ==="
          puts "Current.organization.lists.count: #{Current.organization.lists.count}"
          puts "Current.organization.lists.pluck(:id, :name): #{Current.organization.lists.pluck(:id, :name)}"
          puts "List.accessible_by(user).pluck(:id, :name): #{List.accessible_by(user).pluck(:id, :name)}"
        end

        it 'returns all lists accessible to the user' do
          debug_request('/api/v1/lists?include=shared')
          get '/api/v1/lists?include=shared', headers: @headers
          
          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(2)
          
          list_names = data['data'].map { |list| list['attributes']['name'] }
          expect(list_names).to include('My List', 'Shared List')
        end
      end
    end

    context 'when not authenticated' do
      before do
        # Reset Current.organization and Current.user for this test
        allow(Current).to receive(:organization).and_return(nil)
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized' do
        get '/api/v1/lists'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when organization has no lists' do
      it 'returns an empty array' do
        get '/api/v1/lists', headers: @headers

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(data['status']).to eq('success')
        expect(data['data']).to be_empty
        expect(data['meta']['pagination']).to include(
          'current_page' => 1,
          'total_pages' => 0,
          'total_count' => 0
        )
      end
    end
  end

  describe 'GET /api/v1/lists/:id' do
    let!(:list) { create(:list, organization: organization, creator: user) }

    context 'when viewing owned list' do
      it 'returns the list' do
        debug_request("/api/v1/lists/#{list.id}")
        get "/api/v1/lists/#{list.id}", headers: @headers

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(data['status']).to eq('success')
        expect(data['data']['id']).to eq(list.id.to_s)
        expect(data['data']['type']).to eq('list')
        expect(data['data']['attributes']).to include(
          'name',
          'description',
          'visibility',
          'premium',
          'position',
          'created_at',
          'updated_at',
          'restaurant_count'
        )
      end
    end

    context 'when viewing shared list' do
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a share between organizations
        @share = create(:share, 
                       creator: other_user, 
                       source_organization: other_organization,
                       target_organization: organization, 
                       shareable: shared_list, 
                       status: :accepted)
        
        # Debug the setup
        puts "\n=== DEBUG: Shared List Setup ==="
        puts "Shared list: #{shared_list.inspect}"
        puts "Share: #{@share.inspect}"
        puts "User: #{user.inspect}"
        puts "User's organizations: #{user.organizations.pluck(:id, :name)}"
        puts "Current.organization: #{Current.organization.inspect}"
      end

      it 'returns the list' do
        debug_request("/api/v1/lists/#{shared_list.id}")
        get "/api/v1/lists/#{shared_list.id}", headers: @headers
        
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(data['status']).to eq('success')
        expect(data['data']['id']).to eq(shared_list.id.to_s)
      end
    end

    context 'when viewing someone else\'s list' do
      let!(:other_list) { create(:list, organization: other_organization, creator: other_user) }

      it 'returns not found' do
        get "/api/v1/lists/#{other_list.id}", headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list does not exist' do
      it 'returns not found' do
        get '/api/v1/lists/0', headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when not authenticated' do
      before do
        # Reset Current.organization and Current.user for this test
        allow(Current).to receive(:organization).and_return(nil)
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized' do
        get "/api/v1/lists/#{list.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/lists' do
    let(:list_attributes) do
      {
        name: 'New List',
        description: 'A new list',
        visibility: 'public',
        premium: false,
        position: 1
      }
    end

    context 'when creating a valid list' do
      it 'creates the list' do
        debug_request('/api/v1/lists', { list: list_attributes })
        expect {
          post '/api/v1/lists',
               params: { list: list_attributes },
               headers: @headers.merge('Content-Type' => 'application/json'),
               as: :json

          Rails.logger.info "Response status: #{response.status}"
          Rails.logger.info "Response body: #{response.body}"
          
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['attributes']['name']).to eq('New List')
        }.to change(List, :count).by(1)

        # Verify the list belongs to the organization and creator
        list = List.last
        expect(list.organization).to eq(organization)
        expect(list.creator).to eq(user)
      end
    end

    context 'when creating an invalid list' do
      let(:invalid_attributes) do
        {
          name: '', # Name is required
          description: 'A new list',
          visibility: 'public',
          premium: false,
          position: 1
        }
      end

      it 'returns validation errors' do
        expect {
          post '/api/v1/lists',
               params: { list: invalid_attributes },
               headers: @headers.merge('Content-Type' => 'application/json'),
               as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors']).to be_present
        }.not_to change(List, :count)
      end
    end

    context 'when not authenticated' do
      before do
        # Reset Current.organization and Current.user for this test
        allow(Current).to receive(:organization).and_return(nil)
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized' do
        post '/api/v1/lists',
             params: { list: list_attributes },
             headers: { 'Content-Type' => 'application/json' },
             as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/lists/:id' do
    let!(:list) { create(:list, organization: organization, creator: user, name: 'Original Name') }
    let(:list_attributes) do
      {
        name: 'Updated Name',
        description: 'Updated description',
        visibility: 'private',
        premium: true,
        position: 2
      }
    end

    context 'when updating owned list' do
      it 'updates the list' do
        debug_request("/api/v1/lists/#{list.id}", { list: list_attributes })
        patch "/api/v1/lists/#{list.id}",
              params: { list: list_attributes },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        Rails.logger.info "Response status: #{response.status}"
        Rails.logger.info "Response body: #{response.body}"
        
        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['attributes']['name']).to eq('Updated Name')
        expect(data['data']['attributes']['description']).to eq('Updated description')
        expect(data['data']['attributes']['visibility']).to eq('private')
        expect(data['data']['attributes']['premium']).to eq(true)
        expect(data['data']['attributes']['position']).to eq(2)

        # Verify the database was updated
        list.reload
        expect(list.name).to eq('Updated Name')
      end
    end

    context 'when updating with invalid attributes' do
      let(:invalid_attributes) do
        {
          name: '', # Name is required
          description: 'Updated description'
        }
      end

      it 'returns validation errors' do
        patch "/api/v1/lists/#{list.id}",
              params: { list: invalid_attributes },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors']).to be_present

        # Verify the database was not updated
        list.reload
        expect(list.name).to eq('Original Name')
      end
    end

    context 'when updating someone else\'s list' do
      let!(:other_list) { create(:list, organization: other_organization, creator: other_user) }

      it 'returns not found' do
        patch "/api/v1/lists/#{other_list.id}",
              params: { list: list_attributes },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when not authenticated' do
      before do
        # Reset Current.organization and Current.user for this test
        allow(Current).to receive(:organization).and_return(nil)
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized' do
        patch "/api/v1/lists/#{list.id}",
              params: { list: list_attributes },
              headers: { 'Content-Type' => 'application/json' },
              as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when updating a shared list' do
      let(:other_organization) { create(:organization) }
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        create(:share, shareable: shared_list, recipient: user, status: :accepted)
      end

      it 'returns not found' do
        patch "/api/v1/lists/#{shared_list.id}",
              params: { list: list_attributes },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end
  end

  describe 'DELETE /api/v1/lists/:id' do
    let!(:list) { create(:list, organization: organization, creator: user) }

    context 'when deleting owned list' do
      it 'deletes the list' do
        debug_request("/api/v1/lists/#{list.id}")
        expect {
          delete "/api/v1/lists/#{list.id}", headers: @headers

          expect(response).to have_http_status(:no_content)
        }.to change(List, :count).by(-1)
      end
    end

    context 'when deleting someone else\'s list' do
      let(:other_organization) { create(:organization) }
      let!(:other_list) { create(:list, organization: other_organization, creator: other_user) }

      it 'returns not found' do
        expect {
          delete "/api/v1/lists/#{other_list.id}", headers: @headers

          expect(response).to have_http_status(:not_found)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors'].first['code']).to eq('not_found')
        }.not_to change(List, :count)
      end
    end

    context 'when deleting a shared list' do
      let(:other_organization) { create(:organization) }
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        create(:share, shareable: shared_list, recipient: user, status: :accepted)
      end

      it 'returns not found' do
        expect {
          delete "/api/v1/lists/#{shared_list.id}", headers: @headers

          expect(response).to have_http_status(:not_found)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors'].first['code']).to eq('not_found')
        }.not_to change(List, :count)
      end
    end

    context 'when list does not exist' do
      it 'returns not found' do
        delete '/api/v1/lists/0', headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when not authenticated' do
      before do
        # Reset Current.organization and Current.user for this test
        allow(Current).to receive(:organization).and_return(nil)
        allow(Current).to receive(:user).and_return(nil)
      end

      it 'returns unauthorized' do
        delete "/api/v1/lists/#{list.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
