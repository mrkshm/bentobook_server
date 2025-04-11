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
    puts "\n=== DEBUG: Request to #{path} ==="
    puts "Headers: #{@headers.inspect}"
    puts "Current.organization: #{Current.organization.inspect}"
    puts "Params: #{params.inspect}" if params
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

      context 'with different list types' do
        let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

        before do
          # Create a share between organizations
          share = create(:share,
                         source_organization: other_organization,
                         target_organization: organization,
                         creator: other_user, # Add creator for the share
                         shareable: shared_list,
                         status: :accepted)

          # Add debugging to help diagnose the issue
          puts "Created a share: #{share.inspect}"
          puts "Connected to shareable: #{share.shareable.inspect}"
          puts "Target organization: #{share.target_organization.inspect}"

          # Verify the share exists in database
          shares = Share.where(target_organization: organization, status: :accepted)
          puts "Found #{shares.count} shares for target_organization before test"
        end

        it 'includes shared lists when requested' do
          get '/api/v1/lists?include=shared', headers: @headers

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}" if response.status != 200

          data = JSON.parse(response.body) rescue nil
          puts "Parsed data: #{data ? 'YES' : 'NO'}"

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data['data'].length).to eq(3) # 2 owned + 1 shared
        end

        it 'includes only accepted shared lists when requested' do
          # Create another shared list with pending status
          pending_list = create(:list, organization: other_organization, creator: other_user)
          create(:share,
                 source_organization: other_organization,
                 target_organization: organization,
                 shareable: pending_list,
                 status: :pending)

          get '/api/v1/lists?include=accepted', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(1) # Only the accepted shared list
        end

        it 'includes only pending shared lists when requested' do
          # Create another shared list with pending status
          pending_list = create(:list, organization: other_organization, creator: other_user)
          create(:share,
                 source_organization: other_organization,
                 target_organization: organization,
                 shareable: pending_list,
                 status: :pending)

          get '/api/v1/lists?include=pending', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(1) # Only the pending shared list
        end
      end

      context 'with search' do
        before do
          List.destroy_all # Clear existing lists
          create(:list, name: "Coffee Shops", description: "Great places for coffee", organization: organization, creator: user)
          create(:list, name: "Italian Restaurants", description: "Best pasta in town", organization: organization, creator: user)
          create(:list, name: "Sushi Bars", description: "Fresh fish and rolls", organization: organization, creator: user)
        end

        it 'filters lists by search query in name' do
          get '/api/v1/lists?search=coffee', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(1)
          expect(data['data'].first['attributes']['name']).to eq('Coffee Shops')
        end

        it 'filters lists by search query in description' do
          get '/api/v1/lists?search=pasta', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(1)
          expect(data['data'].first['attributes']['name']).to eq('Italian Restaurants')
        end

        it 'returns empty array when no matches found' do
          get '/api/v1/lists?search=burger', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(0)
        end
      end

      context 'with sorting' do
        before do
          List.destroy_all # Clear existing lists
          create(:list, name: "Z List", created_at: 3.days.ago, updated_at: 3.days.ago, organization: organization, creator: user)
          create(:list, name: "A List", created_at: 1.day.ago, updated_at: 1.day.ago, organization: organization, creator: user)
          create(:list, name: "M List", created_at: 2.days.ago, updated_at: 2.hours.ago, organization: organization, creator: user)
        end

        it 'sorts lists by name' do
          get '/api/v1/lists?order_by=name&order_direction=asc', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(3)
          expect(data['data'].first['attributes']['name']).to eq('A List')
          expect(data['data'].last['attributes']['name']).to eq('Z List')
        end

        it 'sorts lists by created_at' do
          get '/api/v1/lists?order_by=created_at&order_direction=desc', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(3)
          expect(data['data'].first['attributes']['name']).to eq('A List') # Most recently created
          expect(data['data'].last['attributes']['name']).to eq('Z List')  # Oldest
        end

        it 'sorts lists by updated_at' do
          get '/api/v1/lists?order_by=updated_at&order_direction=desc', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(3)
          expect(data['data'].first['attributes']['name']).to eq('M List') # Most recently updated
          expect(data['data'].last['attributes']['name']).to eq('Z List')  # Least recently updated
        end
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

        it 'handles page overflow gracefully' do
          get '/api/v1/lists?per_page=3&page=10', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(1) # Last page with 1 item
          expect(data['meta']['pagination']).to include(
            'current_page' => 3,
            'total_pages' => 3,
            'total_count' => 7
          )
        end
      end
    end

    context 'when organization has no lists' do
      it 'returns an empty array with pagination metadata' do
        get '/api/v1/lists', headers: @headers

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(data['data']).to be_empty
        expect(data['meta']['pagination']).to include(
          'current_page' => 1,
          'total_pages' => 0,
          'total_count' => 0
        )
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
  end

  describe 'GET /api/v1/lists/:id' do
    let!(:list) { create(:list, organization: organization, creator: user) }

    context 'when accessing owned list' do
      it 'returns the list' do
        get "/api/v1/lists/#{list.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['id']).to eq(list.id.to_s)
        expect(data['data']['type']).to eq('list')
        expect(data['data']['attributes']['name']).to eq(list.name)
      end
    end

    context 'when accessing shared list' do
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a share between organizations
        create(:share,
               source_organization: other_organization,
               target_organization: organization,
               shareable: shared_list,
               status: :accepted)
      end

      it 'returns the shared list' do
        get "/api/v1/lists/#{shared_list.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['id']).to eq(shared_list.id.to_s)
      end
    end

    context 'when accessing pending shared list' do
      let!(:pending_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a pending share between organizations
        create(:share,
               source_organization: other_organization,
               target_organization: organization,
               shareable: pending_list,
               status: :pending)
      end

      it 'returns not found' do
        get "/api/v1/lists/#{pending_list.id}", headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when accessing another organization\'s list' do
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
        name: 'My New List',
        description: 'A list of restaurants to try',
        visibility: 'personal'
      }
    end

    context 'when creating a list' do
      it 'creates a new list' do
        expect {
          post '/api/v1/lists',
               params: { list: list_attributes },
               headers: @headers.merge('Content-Type' => 'application/json'),
               as: :json

          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['attributes']['name']).to eq('My New List')
        }.to change(List, :count).by(1)

        # Verify the list belongs to the current organization
        expect(List.last.organization).to eq(organization)
        expect(List.last.creator).to eq(user)
      end

      it 'returns validation errors for invalid list' do
        expect {
          post '/api/v1/lists',
               params: { list: { name: '' } },
               headers: @headers.merge('Content-Type' => 'application/json'),
               as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors'].first['detail']).to include("Name can't be blank")
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
    let!(:list) { create(:list, organization: organization, creator: user) }
    let(:list_attributes) do
      {
        name: 'Updated List Name',
        description: 'Updated description'
      }
    end

    context 'when updating owned list' do
      it 'updates the list' do
        patch "/api/v1/lists/#{list.id}",
              params: { list: list_attributes },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['attributes']['name']).to eq('Updated List Name')
        expect(data['data']['attributes']['description']).to eq('Updated description')

        # Verify the database was updated
        list.reload
        expect(list.name).to eq('Updated List Name')
        expect(list.description).to eq('Updated description')
      end

      it 'returns validation errors for invalid update' do
        patch "/api/v1/lists/#{list.id}",
              params: { list: { name: '' } },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['detail']).to include("Name can't be blank")

        # Verify the database was not updated
        list.reload
        expect(list.name).not_to eq('')
      end
    end

    context 'when updating another organization\'s list' do
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

    context 'when updating a shared list' do
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a share between organizations
        create(:share,
               source_organization: other_organization,
               target_organization: organization,
               shareable: shared_list,
               status: :accepted)
      end

      it 'returns forbidden' do
        patch "/api/v1/lists/#{shared_list.id}",
              params: { list: list_attributes },
              headers: @headers.merge('Content-Type' => 'application/json'),
              as: :json

        expect(response).to have_http_status(:forbidden)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('forbidden')
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

    context 'when deleting another organization\'s list' do
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
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a share between organizations
        create(:share,
               source_organization: other_organization,
               target_organization: organization,
               shareable: shared_list,
               status: :accepted)
      end

      it 'returns forbidden' do
        expect {
          delete "/api/v1/lists/#{shared_list.id}", headers: @headers

          expect(response).to have_http_status(:forbidden)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['errors'].first['code']).to eq('forbidden')
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

  describe 'POST /api/v1/lists/:id/accept_share' do
    let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }
    let!(:share) { create(:share,
                          source_organization: other_organization,
                          target_organization: organization,
                          shareable: shared_list,
                          status: :pending) }

    it 'accepts a pending share invitation' do
      post "/api/v1/lists/#{shared_list.id}/accept_share", headers: @headers

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['status']).to eq('success')

      # Verify the share status was updated
      expect(share.reload.status).to eq('accepted')
    end

    it 'returns not found for non-existent share' do
      another_list = create(:list, organization: other_organization, creator: other_user)

      post "/api/v1/lists/#{another_list.id}/accept_share", headers: @headers

      expect(response).to have_http_status(:not_found)
      data = JSON.parse(response.body)
      expect(data['status']).to eq('error')
      expect(data['errors'].first['code']).to eq('not_found')
    end
  end

  describe 'POST /api/v1/lists/:id/decline_share' do
    let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }
    let!(:share) { create(:share,
                          source_organization: other_organization,
                          target_organization: organization,
                          shareable: shared_list,
                          status: :pending) }

    it 'declines and removes a pending share invitation' do
      expect {
        post "/api/v1/lists/#{shared_list.id}/decline_share", headers: @headers

        expect(response).to have_http_status(:no_content)
      }.to change(Share, :count).by(-1)
    end

    it 'returns not found for non-existent share' do
      another_list = create(:list, organization: other_organization, creator: other_user)

      post "/api/v1/lists/#{another_list.id}/decline_share", headers: @headers

      expect(response).to have_http_status(:not_found)
      data = JSON.parse(response.body)
      expect(data['status']).to eq('error')
      expect(data['errors'].first['code']).to eq('not_found')
    end
  end

  describe 'DELETE /api/v1/lists/:id/remove_share' do
    let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }
    let!(:share) { create(:share,
                          source_organization: other_organization,
                          target_organization: organization,
                          shareable: shared_list,
                          status: :accepted) }

    it 'removes an accepted share' do
      expect {
        delete "/api/v1/lists/#{shared_list.id}/remove_share", headers: @headers

        expect(response).to have_http_status(:no_content)
      }.to change(Share, :count).by(-1)
    end

    it 'returns not found for non-existent share' do
      # Create a list without a share
      another_list = create(:list, organization: other_organization, creator: other_user)

      delete "/api/v1/lists/#{another_list.id}/remove_share", headers: @headers

      expect(response).to have_http_status(:not_found)
      data = JSON.parse(response.body)
      expect(data['status']).to eq('error')
      expect(data['errors'].first['code']).to eq('not_found')
    end
  end
end
