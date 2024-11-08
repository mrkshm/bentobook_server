require 'swagger_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }
  let(:Authorization) { "Bearer #{token}" }

  path '/api/v1/restaurants' do
    get 'Lists restaurants' do
      tags 'Restaurants'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'restaurants found' do
        before do
          create_list(:restaurant, 3, user: user)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('restaurants')
          expect(data).to have_key('pagy')
          expect(data).to have_key('sorting')
          expect(data['restaurants'].length).to eq(3)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post 'Creates a restaurant' do
      tags 'Restaurants'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      
      parameter name: :restaurant, in: :body, schema: {
        type: :object,
        properties: {
          restaurant: {
            type: :object,
            properties: {
              name: { type: :string },
              address: { type: :string },
              city: { type: :string },
              latitude: { type: :number },
              longitude: { type: :number },
              notes: { type: :string },
              rating: { type: :integer },
              price_level: { type: :integer },
              google_place_id: { type: :string },
              cuisine_type: { type: :string }
            },
            required: ['name', 'address', 'city', 'latitude', 'longitude', 'google_place_id', 'cuisine_type']
          }
        },
        required: ['restaurant']
      }

      let(:restaurant_params) do
        {
          name: 'Test Restaurant',
          address: '123 Test St',
          city: 'Test City',
          latitude: 40.7128,
          longitude: -74.006,
          notes: 'Great place!',
          rating: 5,
          price_level: 2,
          google_place_id: 'test_place_id',
          cuisine_type: 'Italian'
        }
      end

      let(:restaurant) { { restaurant: restaurant_params } }

      response '201', 'restaurant created' do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('name')
          expect(data).to have_key('address')
          # Additional expectations can be added here
        end
      end

      response '422', 'invalid request' do
        let(:restaurant) { { restaurant: { name: 'Incomplete Restaurant' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include("Google restaurant must exist")
        end
      end
    end
  end

  path '/api/v1/restaurants/{id}' do
    get 'Retrieves a restaurant' do
      tags 'Restaurants'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'restaurant found' do
        let(:id) { create(:restaurant, user: user).id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('id')
          expect(data).to have_key('name')
          expect(data).to have_key('address')
        end
      end

      response '404', 'restaurant not found' do
        let(:id) { 'invalid' }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end

    delete 'Deletes a restaurant' do
      tags 'Restaurants'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'restaurant deleted' do
        let(:id) { create(:restaurant, user: user).id }

        run_test! do |response|
          expect(response.status).to eq(200)
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Restaurant was successfully removed from your list.')
        end
      end

      response '404', 'restaurant not found' do
        let(:id) { 'invalid' }

        run_test! do |response|
          expect(response.status).to eq(404)
        end
      end
    end
  end

  path '/api/v1/restaurants/{id}/add_tag' do
    post 'Adds a tag to a restaurant' do
      tags 'Restaurants'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :tag, in: :query, type: :string

      let(:restaurant) { create(:restaurant, user: user) }
      let(:id) { restaurant.id }

      response '200', 'tag added successfully' do
        let(:tag) { 'italian' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Tag added successfully.')
          expect(data['tags']).to include('italian')
        end

        it 'does not duplicate existing tags' do
          # First add the tag
          post "/api/v1/restaurants/#{id}/add_tag", params: { tag: 'italian' }, 
            headers: { 'Authorization' => "Bearer #{token}" }
          
          # Try to add the same tag again
          post "/api/v1/restaurants/#{id}/add_tag", params: { tag: 'italian' }, 
            headers: { 'Authorization' => "Bearer #{token}" }
          
          data = JSON.parse(response.body)
          expect(data['tags'].count('italian')).to eq(1)
        end
      end
    end
  end

  path '/api/v1/restaurants/{id}/remove_tag' do
    delete 'Removes a tag from a restaurant' do
      tags 'Restaurants'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :tag, in: :query, type: :string

      let(:restaurant) { create(:restaurant, user: user) }
      let(:id) { restaurant.id }

      response '200', 'tag removed successfully' do
        let(:tag) { 'italian' }

        before do
          restaurant.tag_list.add('italian')
          restaurant.save!
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Tag removed successfully.')
          expect(data['tags']).not_to include('italian')
        end
      end
    end
  end
end
