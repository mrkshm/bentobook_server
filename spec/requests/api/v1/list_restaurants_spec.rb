require 'rails_helper'

RSpec.describe 'Api::V1::ListRestaurants', type: :request do
  let(:user) { create(:user) }
  let(:organization) { user.organizations.first }
  let(:other_user) { create(:user) }
  let(:other_organization) { other_user.organizations.first }
  let(:headers) { sign_in_with_token(user) }
  let(:list) { create(:list, organization: organization, creator: user) }
  let(:restaurant) { create(:restaurant) }

  before do
    @headers = headers
    set_current_organization(organization)
  end

  # Helper to set Current.organization and ensure it persists during requests
  def set_current_organization(org)
    Current.organization = org
    allow(Current).to receive(:organization).and_return(org)
  end

  # Helper to reset json_response between requests
  def reset_json_response
    @json_response = nil
  end

  # Helper to add debug output
  def debug_request(path, params = nil)
    Rails.logger.info "\n=== DEBUG: Request to #{path} ===" 
    Rails.logger.info "Headers: #{@headers.inspect}"
    Rails.logger.info "Current.organization: #{Current.organization.inspect}"
    Rails.logger.info "Params: #{params.inspect}" if params
  end

  after do
    # Reset Current.organization to avoid affecting other tests
    allow(Current).to receive(:organization).and_call_original
    allow(Current).to receive(:user).and_call_original
  end

  describe 'POST /api/v1/lists/:list_id/restaurants' do
    context 'when adding restaurant to owned list' do
      it 'adds the restaurant' do
        expect {
          post "/api/v1/lists/#{list.id}/restaurants",
               params: { restaurant_id: restaurant.id }.to_json,
               headers: @headers.merge('Content-Type' => 'application/json')

          expect(response).to have_http_status(:success)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['attributes']['restaurants'])
            .to include(include('id' => restaurant.id))
        }.to change { list.restaurants.count }.by(1)
      end
    end

    context 'when restaurant does not exist' do
      it 'returns not found' do
        post "/api/v1/lists/#{list.id}/restaurants",
             params: { restaurant_id: 0 }.to_json,
             headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list does not exist' do
      it 'returns not found' do
        post "/api/v1/lists/0/restaurants",
             params: { restaurant_id: restaurant.id }.to_json,
             headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list belongs to another organization' do
      let(:other_list) { create(:list, organization: other_organization, creator: other_user) }

      it 'returns not found' do
        post "/api/v1/lists/#{other_list.id}/restaurants",
             params: { restaurant_id: restaurant.id }.to_json,
             headers: @headers.merge('Content-Type' => 'application/json')

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list is shared with the organization' do
      let(:shared_list) { create(:list, organization: other_organization, creator: other_user) }

      before do
        # Create a share from other_organization to organization
        create(:share, 
               source_organization: other_organization, 
               target_organization: organization, 
               shareable: shared_list,
               status: :accepted,
               permission: :edit)
      end

      it 'allows adding a restaurant to the shared list' do
        expect {
          post "/api/v1/lists/#{shared_list.id}/restaurants",
               params: { restaurant_id: restaurant.id }.to_json,
               headers: @headers.merge('Content-Type' => 'application/json')

          expect(response).to have_http_status(:success)
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['data']['attributes']['restaurants'])
            .to include(include('id' => restaurant.id))
        }.to change { shared_list.restaurants.count }.by(1)
      end
    end
  end

  describe 'DELETE /api/v1/lists/:list_id/restaurants/:id' do
    before do
      list.restaurants << restaurant
    end

    context 'when removing restaurant from owned list' do
      it 'removes the restaurant' do
        expect {
          delete "/api/v1/lists/#{list.id}/restaurants/#{restaurant.id}",
                 headers: @headers

          expect(response).to have_http_status(:no_content)
        }.to change { list.restaurants.count }.by(-1)
      end
    end

    context 'when restaurant is not in list' do
      let(:other_restaurant) { create(:restaurant) }

      it 'returns not found' do
        delete "/api/v1/lists/#{list.id}/restaurants/#{other_restaurant.id}",
               headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list does not exist' do
      it 'returns not found' do
        delete "/api/v1/lists/0/restaurants/#{restaurant.id}",
               headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list belongs to another organization' do
      let(:other_list) { create(:list, organization: other_organization, creator: other_user) }
      let(:other_restaurant) { create(:restaurant) }

      before do
        other_list.restaurants << other_restaurant
      end

      it 'returns not found' do
        delete "/api/v1/lists/#{other_list.id}/restaurants/#{other_restaurant.id}",
               headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list is shared with the organization' do
      let(:shared_list) { create(:list, organization: other_organization, creator: other_user) }
      let(:shared_restaurant) { create(:restaurant) }

      before do
        # Create a share from other_organization to organization
        create(:share, 
               source_organization: other_organization, 
               target_organization: organization, 
               shareable: shared_list,
               status: :accepted,
               permission: :edit)
        
        shared_list.restaurants << shared_restaurant
      end

      it 'allows removing a restaurant from the shared list' do
        expect {
          delete "/api/v1/lists/#{shared_list.id}/restaurants/#{shared_restaurant.id}",
                 headers: @headers

          expect(response).to have_http_status(:no_content)
        }.to change { shared_list.restaurants.count }.by(-1)
      end
    end
  end
end
