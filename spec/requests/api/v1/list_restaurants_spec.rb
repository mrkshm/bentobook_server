require 'rails_helper'

RSpec.describe 'Api::V1::ListRestaurants', type: :request do
  let(:user) { create(:user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
  end
  let(:list) { create(:list, owner: user) }
  let(:restaurant) { create(:restaurant) }

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
  end

  describe 'POST /api/v1/lists/:list_id/restaurants' do
    context 'when adding restaurant to owned list' do
      it 'adds the restaurant' do
        expect {
          post "/api/v1/lists/#{list.id}/restaurants",
               params: { restaurant_id: restaurant.id },
               headers: @headers

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
             params: { restaurant_id: 0 },
             headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
      end
    end

    context 'when list does not exist' do
      it 'returns not found' do
        post "/api/v1/lists/0/restaurants",
             params: { restaurant_id: restaurant.id },
             headers: @headers

        expect(response).to have_http_status(:not_found)
        data = JSON.parse(response.body)
        expect(data['status']).to eq('error')
        expect(data['errors'].first['code']).to eq('not_found')
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
  end
end
