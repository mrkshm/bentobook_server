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
    allow(Current).to receive(:organization).and_return(organization)
    allow(Current).to receive(:user).and_return(user)
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

  describe 'GET /api/v1/lists' do
    context 'when organization has lists' do
      before do
        create_list(:list, 2, organization: organization, creator: user)
        create(:list, organization: other_organization, creator: other_user) # another organization's list
      end

      it 'returns only organization owned lists by default' do
        Rails.logger.info "Making request with headers: #{@headers.inspect}"
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
      end

      context 'when no lists exist' do
        before { List.destroy_all }

        it 'returns empty data with correct pagination' do
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
    end

    context 'when include=shared' do
      let(:other_organization) { create(:organization) }
      let!(:owned_list) { create(:list, organization: organization, creator: user) }
      let!(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        create(:share, shareable: shared_list, recipient: user, status: :accepted)
      end

      it 'returns both owned and shared lists' do
        Rails.logger.info "Making request with headers: #{@headers.inspect}"
        get '/api/v1/lists?include=shared', headers: @headers
        Rails.logger.info "Response status: #{response.status}"
        Rails.logger.info "Response body: #{response.body}"

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(data['status']).to eq('success')
        expect(data['data'].length).to eq(2)
        list_ids = data['data'].map { |l| l['id'] }
        expect(list_ids).to include(owned_list.id.to_s, shared_list.id.to_s)
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        # Clear Current.user and Current.organization for this test
        allow(Current).to receive(:user).and_return(nil)
        allow(Current).to receive(:organization).and_return(nil)
        
        get '/api/v1/lists'

        data = JSON.parse(response.body)
        expect(response).to have_http_status(:unauthorized)
        expect(data['status']).to eq('error')
        expect(data['errors']).to be_an(Array)
        expect(data['errors'].first['code']).to eq('unauthorized')
        expect(data['meta']).to include('timestamp')
      end
    end
  end

  describe 'GET /api/v1/lists/:id' do
    context 'when viewing owned list' do
      let!(:list) { create(:list, organization: organization, creator: user) }

      it 'returns the list' do
        get "/api/v1/lists/#{list.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['type']).to eq('list')
        expect(data['data']['id']).to eq(list.id.to_s)
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
      let(:other_organization) { create(:organization) }
      let!(:list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        create(:share, shareable: list, recipient: user, status: :accepted)
      end

      it 'returns the list' do
        get "/api/v1/lists/#{list.id}", headers: @headers

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['type']).to eq('list')
        expect(data['data']['id']).to eq(list.id.to_s)
      end
    end

    context 'when viewing someone else\'s list' do
      let(:other_organization) { create(:organization) }
      let!(:list) { create(:list, organization: other_organization, creator: other_user) }

      it 'returns not found' do
        get "/api/v1/lists/#{list.id}", headers: @headers

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
      let!(:list) { create(:list, organization: organization, creator: user) }

      it 'returns unauthorized' do
        # Clear Current.user and Current.organization for this test
        allow(Current).to receive(:user).and_return(nil)
        allow(Current).to receive(:organization).and_return(nil)
        
        get "/api/v1/lists/#{list.id}"

        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('unauthorized')
      end
    end
  end

  describe 'POST /api/v1/lists' do
    let(:list_attributes) do
      {
        name: 'My Favorite Restaurants',
        description: 'A collection of my favorite spots',
        visibility: 'personal',
        premium: false,
        position: 1
      }
    end

    context 'with valid parameters' do
      it 'creates a new list' do
        expect {
          post '/api/v1/lists',
               params: { list: list_attributes }.to_json,
               headers: @headers.merge('Content-Type' => 'application/json')

          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['type']).to eq('list')
          expect(data['data']['attributes']).to include(
            'name' => list_attributes[:name],
            'description' => list_attributes[:description],
            'visibility' => list_attributes[:visibility],
            'premium' => list_attributes[:premium],
            'position' => list_attributes[:position]
          )
        }.to change(List, :count).by(1)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for missing required fields' do
        post '/api/v1/lists',
             params: { list: { description: 'Invalid list without name' } }.to_json,
             headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors']).to include(
          hash_including(
            'code' => 'validation_error',
            'source' => { 'pointer' => '/data/attributes/name' }
          )
        )
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        # Clear Current.user and Current.organization for this test
        allow(Current).to receive(:user).and_return(nil)
        allow(Current).to receive(:organization).and_return(nil)
        
        post '/api/v1/lists', params: { list: list_attributes }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('unauthorized')
      end
    end
  end

  describe 'PATCH /api/v1/lists/:id' do
    let!(:list) { create(:list, organization: organization, creator: user, name: 'Original Name') }
    let(:list_attributes) { { name: 'Updated Name' } }

    context 'with valid parameters' do
      it 'updates the list' do
        patch "/api/v1/lists/#{list.id}",
              params: { list: list_attributes }.to_json,
              headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('success')
        expect(data['data']['type']).to eq('list')
        expect(data['data']['attributes']['name']).to eq('Updated Name')
        expect(list.reload.name).to eq('Updated Name')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        patch "/api/v1/lists/#{list.id}",
              params: { list: { name: '' } }.to_json,
              headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:unprocessable_entity)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors']).to include(
          hash_including(
            'code' => 'validation_error',
            'source' => { 'pointer' => '/data/attributes/name' }
          )
        )
      end
    end

    context 'when updating someone else\'s list' do
      let(:other_organization) { create(:organization) }
      let!(:other_list) { create(:list, organization: other_organization, creator: other_user) }

      it 'returns not found' do
        patch "/api/v1/lists/#{other_list.id}",
              params: { list: list_attributes }.to_json,
              headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list does not exist' do
      it 'returns not found' do
        patch '/api/v1/lists/0',
              params: { list: list_attributes }.to_json,
              headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        # Clear Current.user and Current.organization for this test
        allow(Current).to receive(:user).and_return(nil)
        allow(Current).to receive(:organization).and_return(nil)
        
        patch "/api/v1/lists/#{list.id}", params: { list: list_attributes }.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('unauthorized')
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
              params: { list: list_attributes }.to_json,
              headers: @headers.merge('Content-Type' => 'application/json')

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
      it 'returns unauthorized' do
        # Clear Current.user and Current.organization for this test
        allow(Current).to receive(:user).and_return(nil)
        allow(Current).to receive(:organization).and_return(nil)
        
        delete "/api/v1/lists/#{list.id}"

        expect(response).to have_http_status(:unauthorized)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('unauthorized')
      end
    end
  end
end
