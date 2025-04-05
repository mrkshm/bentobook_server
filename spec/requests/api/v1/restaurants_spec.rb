require 'rails_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  before(:all) do
    Pagy::DEFAULT[:items] ||= 10
  end

  let(:user) { create(:user) }
  let(:organization) { user.organizations.first } # User gets an org automatically on creation
  let(:italian_cuisine) { create(:cuisine_type, name: 'italian') }

  let(:restaurant_attributes) do
    {
      name: 'Test Restaurant',
      cuisine_type_name: 'italian',
      google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
      address: '123 Test St',
      city: 'Test City',
      latitude: 40.7128,
      longitude: -74.0060,
      price_level: 2,
      rating: 4.5,
      notes: 'Great place!',
      tag_list: [ 'pasta', 'wine' ]
    }
  end

  before do
    italian_cuisine # ensure cuisine type exists
    puts "DEBUG: Before signing in user: #{user.inspect}"
    sign_in user
    puts "DEBUG: After signing in user"
    puts "DEBUG: Is user signed in? #{user.reload.sign_in_count > 0}"
    Current.organization = organization
  end

  after do
    Current.organization = nil
  end

  describe 'GET /api/v1/restaurants' do
    context 'with no restaurants' do
      it 'returns an empty list' do
        get '/api/v1/restaurants'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']).to be_empty
        expect(json_response['meta']).to include('timestamp')
        expect(json_response['meta']['pagination']).to include(
          'current_page' => 1,
          'total_pages' => 0,
          'total_count' => 0,
          'per_page' => Pagy::DEFAULT[:items].to_s
        )
      end
    end

    context 'with multiple restaurants' do
      let!(:restaurant1) { create(:restaurant, organization: organization, name: 'First Restaurant') }
      let!(:restaurant2) { create(:restaurant, organization: organization, name: 'Second Restaurant') }

      it 'returns all restaurants' do
        get '/api/v1/restaurants'

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data'].length).to eq(2)
        expect(json_response['data'].first['type']).to eq('restaurant')
        expect(json_response['data'].first['attributes']).to include(
          'name',
          'location',
          'contact_info',
          'rating',
          'price_level',
          'tags'
        )
      end

      context 'with sorting' do
        it 'sorts by name' do
          get '/api/v1/restaurants', params: { order_by: 'name', order_direction: 'asc' }

          names = json_response['data'].map { |r| r['attributes']['name'] }
          expect(names).to eq(names.sort)
        end

        it 'sorts by created_at' do
          get '/api/v1/restaurants', params: { order_by: 'created_at', order_direction: 'desc' }

          dates = json_response['data'].map { |r| Time.parse(r['attributes']['created_at']) }
          expect(dates).to eq(dates.sort.reverse)
        end
      end

      context 'with filtering' do
        let!(:tagged_restaurant) { create(:restaurant, organization: organization, name: 'Tagged Restaurant') }

        before do
          tagged_restaurant.tag_list.add('italian')
          tagged_restaurant.save!
        end

        it 'filters by tag' do
          get '/api/v1/restaurants', params: { tag: 'italian' }

          expect(response).to have_http_status(:ok)
          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('Tagged Restaurant')
        end

        it 'filters by search term' do
          get '/api/v1/restaurants', params: { search: 'Tagged' }

          expect(response).to have_http_status(:ok)
          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('Tagged Restaurant')
        end
      end

      context 'with location' do
        let!(:nearby_restaurant) do
          create(:restaurant, organization: organization,
                            name: 'Nearby Place',
                            latitude: 40.7128,
                            longitude: -74.0060)
        end

        it 'includes distance when coordinates provided' do
          get '/api/v1/restaurants', params: { latitude: 40.7128, longitude: -74.0060 }

          expect(response).to have_http_status(:ok)
          expect(json_response['data'].first['attributes']).to include('distance')
        end
      end

      context 'when an error occurs' do
        before do
          allow_any_instance_of(RestaurantQuery).to receive(:call).and_raise(StandardError.new('Query failed'))
        end

        it 'returns an error response' do
          get '/api/v1/restaurants'

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Query failed')
        end
      end
    end
  end

  describe 'POST /api/v1/restaurants' do
    context 'with valid parameters' do
      it 'creates a new restaurant' do
        expect {
          post '/api/v1/restaurants', params: { restaurant: restaurant_attributes }
        }.to change(Restaurant, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['name']).to eq(restaurant_attributes[:name])
      end

      it 'handles tags' do
        post '/api/v1/restaurants', params: { restaurant: restaurant_attributes }

        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['tags']).to match_array(restaurant_attributes[:tag_list])
      end

      context 'with images' do
        let(:image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
        let(:non_image) { fixture_file_upload('spec/fixtures/test.txt', 'text/plain') }

        it 'only processes files with image content type' do
          post '/api/v1/restaurants',
               params: { restaurant: restaurant_attributes.merge(images: [image, non_image]) }

          expect(response).to have_http_status(:created)
          # Add expectations for image processing based on your implementation
        end
      end

      context 'when creating with rating' do
        it 'creates restaurant with integer rating' do
          attributes = restaurant_attributes.merge(rating: '4')
          
          post '/api/v1/restaurants', params: { restaurant: attributes }

          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['rating']).to eq(4)
        end
      end

      context 'when creating without rating' do
        it 'creates restaurant with nil rating' do
          attributes = restaurant_attributes.merge(rating: nil)
          
          post '/api/v1/restaurants', params: { restaurant: attributes }

          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['rating']).to be_nil
        end
      end

      context 'when creating with google_place_id' do
        context 'with different coordinates' do
          it 'creates google restaurant with coordinates' do
            attributes = restaurant_attributes.merge(
              latitude: '40.7128',
              longitude: '-74.0060'
            )
            
            post '/api/v1/restaurants', params: { restaurant: attributes }

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(40.7128)
            expect(restaurant.google_restaurant.longitude).to eq(-74.0060)
          end
        end

        context 'with default coordinates' do
          it 'creates google restaurant with default coordinates' do
            attributes = restaurant_attributes.merge(
              latitude: nil,
              longitude: nil
            )
            
            post '/api/v1/restaurants', params: { restaurant: attributes }

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(0)
            expect(restaurant.google_restaurant.longitude).to eq(0)
          end
        end
      end

      context 'when creating without google_place_id' do
        context 'with different coordinates' do
          it 'builds google restaurant with coordinates' do
            attributes = restaurant_attributes.merge(
              google_place_id: nil,
              latitude: '40.7128',
              longitude: '-74.0060'
            )
            
            post '/api/v1/restaurants', params: { restaurant: attributes }

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(40.7128)
            expect(restaurant.google_restaurant.longitude).to eq(-74.0060)
          end
        end

        context 'with default coordinates' do
          it 'builds google restaurant with default coordinates' do
            attributes = restaurant_attributes.merge(
              google_place_id: nil,
              latitude: nil,
              longitude: nil
            )
            
            post '/api/v1/restaurants', params: { restaurant: attributes }

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(0)
            expect(restaurant.google_restaurant.longitude).to eq(0)
          end
        end
      end

      context 'with google_place_id' do
        it 'converts string coordinates to decimal' do
          attributes = restaurant_attributes.merge(
            latitude: '40.7128',
            longitude: '-74.0060'
          )
          
          post '/api/v1/restaurants', params: { restaurant: attributes }

          expect(response).to have_http_status(:created)
          restaurant = Restaurant.last
          expect(restaurant.google_restaurant.latitude).to eq(40.7128)
          expect(restaurant.google_restaurant.longitude).to eq(-74.0060)
        end

        it 'converts invalid coordinates to zero' do
          attributes = restaurant_attributes.merge(
            latitude: 'invalid',
            longitude: 'invalid'
          )
          
          post '/api/v1/restaurants', params: { restaurant: attributes }

          expect(response).to have_http_status(:created)
          restaurant = Restaurant.last
          expect(restaurant.google_restaurant.latitude).to eq(0)
          expect(restaurant.google_restaurant.longitude).to eq(0)
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        post '/api/v1/restaurants', params: { restaurant: { name: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to be_present
      end

      it 'returns error when restaurant params are missing' do
        post '/api/v1/restaurants', params: {}

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
      end

      it 'filters out unpermitted parameters' do
        attributes = restaurant_attributes.merge(unpermitted: 'value')
        
        post '/api/v1/restaurants', params: { restaurant: attributes }

        expect(response).to have_http_status(:created)
        restaurant = Restaurant.last
        expect(restaurant).not_to respond_to(:unpermitted)
      end
    end

    context 'when an error occurs' do
      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all
        @error_restaurant = create(:restaurant, organization: organization, name: "Error Test Restaurant #{Time.current.to_f}")
        allow_any_instance_of(RestaurantSerializer).to receive(:serialize).and_raise(StandardError.new("Failed to serialize restaurant"))
      end

      it 'returns an error response' do
        post '/api/v1/restaurants', params: { restaurant: restaurant_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to eq('Failed to serialize restaurant')
      end
    end
  end

  describe 'when restaurant does not exist' do
    context 'GET /api/v1/restaurants/:id' do
      it 'returns not found error' do
        get '/api/v1/restaurants/0'

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to eq('Restaurant not found')
      end
    end

    context 'PATCH /api/v1/restaurants/:id' do
      it 'returns not found error' do
        patch '/api/v1/restaurants/0', params: { restaurant: restaurant_attributes }

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to eq('Restaurant not found')
      end
    end

    context 'DELETE /api/v1/restaurants/:id' do
      it 'returns not found error' do
        delete '/api/v1/restaurants/0'

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to eq('Restaurant not found')
      end
    end

    context 'POST /api/v1/restaurants/:id/add_tag' do
      it 'returns not found error' do
        post '/api/v1/restaurants/0/add_tag', params: { tag: 'newtag' }

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to eq('Restaurant not found')
      end
    end

    context 'DELETE /api/v1/restaurants/:id/remove_tag' do
      it 'returns not found error' do
        delete '/api/v1/restaurants/0/remove_tag', params: { tag: 'existingtag' }

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['message']).to eq('Restaurant not found')
      end
    end
  end

  describe 'final operations' do
    describe 'POST /api/v1/restaurants/:id/add_tag' do
      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all

        # Create a new restaurant
        @restaurant = create(:restaurant, organization: organization, name: "Tag Test Restaurant #{Time.current.to_f}")
      end

      it 'adds a tag to the restaurant' do
        post "/api/v1/restaurants/#{@restaurant.id}/add_tag", params: { tag: 'newtag' }

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['tags']).to include('newtag')
      end

      context 'when an error occurs' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, organization: organization, name: "Tag Error Restaurant #{Time.current.to_f}")
          allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Failed to save tag"))
        end

        it 'returns an error response' do
          post "/api/v1/restaurants/#{@error_restaurant.id}/add_tag", params: { tag: 'newtag' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Failed to save tag')
        end
      end

      context 'when save fails with validation errors' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, organization: organization, name: "Tag Validation Error Restaurant #{Time.current.to_f}")
          allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Tag name is invalid")
        end

        it 'returns an error response' do
          post "/api/v1/restaurants/#{@error_restaurant.id}/add_tag", params: { tag: 'newtag' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Tag name is invalid')
        end
      end
    end

    describe 'DELETE /api/v1/restaurants/:id/remove_tag' do
      let(:restaurant) { create(:restaurant, organization: organization, name: "Remove Tag Restaurant #{Time.current.to_f}") }

      before do
        restaurant.tag_list.add('existingtag')
        restaurant.save!
      end

      it 'removes a tag from the restaurant' do
        delete "/api/v1/restaurants/#{restaurant.id}/remove_tag", params: { tag: 'existingtag' }

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['tags']).not_to include('existingtag')
      end

      context 'when an error occurs' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, organization: organization, name: "Remove Tag Error Restaurant #{Time.current.to_f}")
          @error_restaurant.tag_list.add('existingtag')
          @error_restaurant.save!
          allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Failed to remove tag"))
        end

        it 'returns an error response' do
          delete "/api/v1/restaurants/#{@error_restaurant.id}/remove_tag", params: { tag: 'existingtag' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Failed to remove tag')
        end
      end

      context 'when save fails with validation errors' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, organization: organization, name: "Remove Tag Validation Error Restaurant #{Time.current.to_f}")
          @error_restaurant.tag_list.add('existingtag')
          @error_restaurant.save!
          allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Tag removal failed")
        end

        it 'returns an error response' do
          delete "/api/v1/restaurants/#{@error_restaurant.id}/remove_tag", params: { tag: 'existingtag' }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Tag removal failed')
        end
      end
    end

    describe 'DELETE /api/v1/restaurants/:id' do
      before do
        @restaurant_to_delete = create(:restaurant, organization: organization, name: "Delete Test Restaurant #{Time.current.to_f}")
      end

      it 'destroys the restaurant' do
        delete "/api/v1/restaurants/#{@restaurant_to_delete.id}"

        expect(response).to have_http_status(:no_content)
      end

      context 'when destroy fails with validation errors' do
        before do
          allow_any_instance_of(Restaurant).to receive(:destroy).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Cannot delete restaurant")
        end

        it 'returns an error response' do
          delete "/api/v1/restaurants/#{@restaurant_to_delete.id}"

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Cannot delete restaurant')
        end
      end

      context 'when destroy raises an error' do
        before do
          allow_any_instance_of(Restaurant).to receive(:destroy).and_raise(StandardError.new("Failed to delete restaurant"))
        end

        it 'returns an error response' do
          delete "/api/v1/restaurants/#{@restaurant_to_delete.id}"

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['message']).to eq('Failed to delete restaurant')
        end
      end
    end
  end
end
