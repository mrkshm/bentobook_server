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

      context 'with shared lists' do
        let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }
        
        before do
          # Create a share from other_organization to organization
          create(:share, 
                 source_organization: other_organization, 
                 target_organization: organization, 
                 shareable: shared_list,
                 status: :accepted)
        end

        it 'includes shared lists when requested' do
          get '/api/v1/lists?include=shared', headers: @headers

          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['data'].length).to eq(3) # 2 owned + 1 shared
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
        # Create a share from other_organization to organization
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
        visibility: 'personal',
        premium: false,
        position: 1
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
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a share from other_organization to organization
        create(:share, 
               source_organization: other_organization, 
               target_organization: organization, 
               shareable: shared_list,
               status: :accepted)
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
        # Create a share from other_organization to organization
        create(:share, 
               source_organization: other_organization, 
               target_organization: organization, 
               shareable: shared_list,
               status: :accepted)
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
