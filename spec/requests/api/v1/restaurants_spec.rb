require 'rails_helper'

RSpec.describe 'Api::V1::Restaurants', type: :request do
  before(:all) do
    Pagy::DEFAULT[:items] ||= 10
  end

  let(:user) { create(:user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
  end
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
    @headers = {}
    sign_in_with_token(user, user_session)
    italian_cuisine # ensure cuisine type exists
  end

  describe 'GET /api/v1/restaurants' do
    context 'with no restaurants' do
      it 'returns an empty list' do
        get '/api/v1/restaurants', headers: @headers

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
      let!(:restaurant1) { create(:restaurant, user: user, name: 'First Restaurant') }
      let!(:restaurant2) { create(:restaurant, user: user, name: 'Second Restaurant') }

      it 'returns all restaurants' do
        get '/api/v1/restaurants', headers: @headers

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
          get '/api/v1/restaurants', params: { order_by: 'name', order_direction: 'asc' }, headers: @headers

          names = json_response['data'].map { |r| r['attributes']['name'] }
          expect(names).to eq(names.sort)
        end

        it 'sorts by created_at' do
          get '/api/v1/restaurants', params: { order_by: 'created_at', order_direction: 'desc' }, headers: @headers

          dates = json_response['data'].map { |r| Time.parse(r['attributes']['created_at']) }
          expect(dates).to eq(dates.sort.reverse)
        end
      end

      context 'with filtering' do
        let!(:tagged_restaurant) { create(:restaurant, user: user, name: 'Tagged Restaurant') }

        before do
          tagged_restaurant.tag_list.add('italian')
          tagged_restaurant.save
        end

        it 'filters by tag' do
          get '/api/v1/restaurants', params: { tag: 'italian' }, headers: @headers

          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('Tagged Restaurant')
        end

        it 'filters by search term' do
          get '/api/v1/restaurants', params: { search: 'First' }, headers: @headers

          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('First Restaurant')
        end
      end

      context 'with location' do
        let!(:nearby_restaurant) do
          create(:restaurant, user: user,
                            name: 'Nearby Place',
                            latitude: 40.7128,
                            longitude: -74.0060)
        end

        it 'includes distance when coordinates provided' do
          get '/api/v1/restaurants',
              params: { latitude: 40.7128, longitude: -74.0060 },
              headers: @headers

          expect(json_response['data'].first['attributes']).to include('distance')
        end
      end

      context 'when an error occurs' do
        before do
          allow_any_instance_of(RestaurantQuery).to receive(:call).and_raise(StandardError.new("Database connection failed"))
        end

        it 'returns an error response' do
          get '/api/v1/restaurants', headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Database connection failed')
        end
      end
    end
  end

  describe 'GET /api/v1/restaurants/:id' do
    let(:restaurant) { create(:restaurant, user: user) }

    it 'returns the restaurant' do
      get "/api/v1/restaurants/#{restaurant.id}", headers: @headers

      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(json_response['data']['id']).to eq(restaurant.id.to_s)
      expect(json_response['data']['type']).to eq('restaurant')
      expect(json_response['data']['attributes']).to include(
        'name',
        'location',
        'contact_info',
        'rating',
        'price_level',
        'tags'
      )
    end

    context 'with visits' do
      let!(:visit) { create(:visit, restaurant: restaurant, user: user) }

      it 'includes visits in the response' do
        get "/api/v1/restaurants/#{restaurant.id}", headers: @headers

        expect(json_response['data']['attributes']['visits'].first).to include(
          'id',
          'date',
          'rating'
        )
      end
    end

    context 'with images' do
      before do
        image = restaurant.images.new
        file_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
        image.file.attach(
          io: File.open(file_path),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
        image.save!
      end

      it 'includes image URLs in the response' do
        get "/api/v1/restaurants/#{restaurant.id}", headers: @headers

        image_data = json_response['data']['attributes']['images'].first
        expect(image_data['urls']).to include(
          'thumbnail',
          'small',
          'medium',
          'large',
          'original'
        )
      end
    end

    context 'when an error occurs' do
      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all
        @error_restaurant = create(:restaurant, user: user, name: "Error Test Restaurant #{Time.current.to_f}")
        allow_any_instance_of(RestaurantSerializer).to receive(:serialize).and_raise(StandardError.new("Failed to serialize restaurant"))
      end

      it 'returns an error response' do
        get "/api/v1/restaurants/#{@error_restaurant.id}", headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'].first['detail']).to eq('Failed to serialize restaurant')
      end
    end
  end

  describe 'POST /api/v1/restaurants' do
    context 'with valid parameters' do
      it 'creates a new restaurant' do
        expect {
          post '/api/v1/restaurants',
               params: { restaurant: restaurant_attributes },
               headers: @headers
        }.to change(Restaurant, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['name']).to eq(restaurant_attributes[:name])
      end

      it 'handles tags' do
        post '/api/v1/restaurants',
             params: { restaurant: restaurant_attributes },
             headers: @headers

        expect(json_response['data']['attributes']['tags']).to match_array([ 'pasta', 'wine' ])
      end

      context 'with images' do
        let(:image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
        let(:non_image) { fixture_file_upload('spec/fixtures/invalid.txt', 'text/plain') }

        it 'only processes files with image content type' do
          post '/api/v1/restaurants',
               params: { restaurant: restaurant_attributes.merge(images: [ image, non_image ]) },
               headers: @headers

          expect(response).to have_http_status(:created)
          restaurant = Restaurant.last
          expect(restaurant.images.count).to eq(1)  # Only the image file should be processed
        end
      end

      context 'when creating with rating' do
        let(:restaurant_params) do
          {
            name: "Test Restaurant with Rating #{Time.current.to_f}",
            cuisine_type_name: 'italian',
            rating: "4",
            address: "123 Test St",
            city: "Test City",
            latitude: "37.7749",
            longitude: "-122.4194",
            google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}"
          }
        end

        it 'creates restaurant with integer rating' do
          post '/api/v1/restaurants', params: { restaurant: restaurant_params }, headers: @headers

          if response.status == 422
            puts "Error response: #{json_response.inspect}"
          end

          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['rating']).to eq(4)
        end
      end

      context 'when creating without rating' do
        let(:restaurant_params) do
          {
            name: "Test Restaurant without Rating #{Time.current.to_f}",
            cuisine_type_name: 'italian',
            address: "123 Test St",
            city: "Test City",
            latitude: "37.7749",
            longitude: "-122.4194",
            google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}"
          }
        end

        it 'creates restaurant with nil rating' do
          post '/api/v1/restaurants', params: { restaurant: restaurant_params }, headers: @headers

          if response.status == 422
            puts "Error response: #{json_response.inspect}"
          end

          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['rating']).to be_nil
        end
      end

      context 'when creating with google_place_id' do
        context 'with different coordinates' do
          let(:restaurant_params) do
            {
              name: "Test Restaurant with Coordinates #{Time.current.to_f}",
              cuisine_type_name: 'italian',
              google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
              address: "123 Test St",
              city: "Test City",
              latitude: "37.7749",
              longitude: "-122.4194"
            }
          end

          it 'creates google restaurant with coordinates' do
            post '/api/v1/restaurants', params: { restaurant: restaurant_params }, headers: @headers

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(37.7749)
            expect(restaurant.google_restaurant.longitude).to eq(-122.4194)
          end
        end

        context 'with default coordinates' do
          let(:restaurant_params) do
            {
              name: "Test Restaurant with Default Coordinates #{Time.current.to_f}",
              cuisine_type_name: 'italian',
              google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}",
              address: "123 Test St",
              city: "Test City",
              latitude: "0.0",
              longitude: "0.0"
            }
          end

          it 'creates google restaurant with default coordinates' do
            post '/api/v1/restaurants', params: { restaurant: restaurant_params }, headers: @headers

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(0.0)
            expect(restaurant.google_restaurant.longitude).to eq(0.0)
          end
        end
      end

      context 'when creating without google_place_id' do
        context 'with different coordinates' do
          let(:restaurant_params) do
            {
              name: "Test Restaurant with Different Coordinates #{Time.current.to_f}",
              cuisine_type_name: 'italian',
              address: "123 Test St",
              city: "Test City",
              latitude: "40.7128",
              longitude: "-74.0060"
            }
          end

          it 'builds google restaurant with coordinates' do
            post '/api/v1/restaurants', params: { restaurant: restaurant_params }, headers: @headers

            if response.status == 422
              puts "Error creating without google_place_id (different coords): #{json_response.inspect}"
            end

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(40.7128)
            expect(restaurant.google_restaurant.longitude).to eq(-74.0060)
          end
        end

        context 'with default coordinates' do
          let(:restaurant_params) do
            {
              name: "Test Restaurant with Default Coordinates #{Time.current.to_f}",
              cuisine_type_name: 'italian',
              address: "123 Test St",
              city: "Test City",
              latitude: "0.0",
              longitude: "0.0"
            }
          end

          it 'builds google restaurant with default coordinates' do
            post '/api/v1/restaurants', params: { restaurant: restaurant_params }, headers: @headers

            if response.status == 422
              puts "Error creating without google_place_id (default coords): #{json_response.inspect}"
            end

            expect(response).to have_http_status(:created)
            restaurant = Restaurant.last
            expect(restaurant.google_restaurant.latitude).to eq(0.0)
            expect(restaurant.google_restaurant.longitude).to eq(0.0)
          end
        end
      end

      context 'with google_place_id' do
        let(:base_params) do
          {
            name: "Test Restaurant #{Time.current.to_f}",
            cuisine_type_name: 'italian',
            address: "123 Test St",
            city: "Test City",
            google_place_id: "PLACE_ID_#{SecureRandom.hex(8)}"
          }
        end

        it 'converts string coordinates to decimal' do
          params = base_params.merge(
            latitude: "37.7749",
            longitude: "-122.4194"
          )

          post '/api/v1/restaurants', params: { restaurant: params }, headers: @headers

          expect(response).to have_http_status(:created)
          restaurant = Restaurant.last
          expect(restaurant.google_restaurant.latitude.class).to eq(BigDecimal)
          expect(restaurant.google_restaurant.longitude.class).to eq(BigDecimal)
          expect(restaurant.google_restaurant.latitude).to eq(BigDecimal("37.7749"))
          expect(restaurant.google_restaurant.longitude).to eq(BigDecimal("-122.4194"))
        end

        it 'converts invalid coordinates to zero' do
          params = base_params.merge(
            latitude: "invalid",
            longitude: "invalid"
          )

          post '/api/v1/restaurants', params: { restaurant: params }, headers: @headers

          expect(response).to have_http_status(:created)
          restaurant = Restaurant.last
          expect(restaurant.google_restaurant.latitude).to eq(0.0)
          expect(restaurant.google_restaurant.longitude).to eq(0.0)
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        post '/api/v1/restaurants',
             params: { restaurant: { rating: 'invalid' } },
             headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors']).to be_present
      end

      it 'returns error when restaurant params are missing' do
        post '/api/v1/restaurants', params: {}, headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'].first['detail']).to eq('param is missing or the value is empty or invalid: restaurant')
      end

      it 'filters out unpermitted parameters' do
        unpermitted_params = restaurant_attributes.merge(
          unpermitted_param: 'should not be included',
          another_unpermitted: 'also should not be included'
        )

        post '/api/v1/restaurants',
             params: { restaurant: unpermitted_params },
             headers: @headers

        expect(response).to have_http_status(:created)
        restaurant = Restaurant.last
        expect(restaurant.attributes).not_to include('unpermitted_param', 'another_unpermitted')
      end
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Database connection lost"))
      end

      it 'returns an error response' do
        post '/api/v1/restaurants',
             params: { restaurant: restaurant_attributes },
             headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'].first['detail']).to eq('Database connection lost')
      end
    end
  end

  describe 'PATCH /api/v1/restaurants/:id' do
    let(:restaurant) { create(:restaurant, user: user) }

    context 'with valid parameters' do
      let(:update_attributes) do
        {
          name: 'Updated Name',
          notes: 'Updated notes',
          tag_list: [ 'updated', 'tags' ]
        }
      end

      it 'updates the restaurant' do
        patch "/api/v1/restaurants/#{restaurant.id}",
              params: { restaurant: update_attributes },
              headers: @headers

        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['name']).to eq('Updated Name')
        expect(json_response['data']['attributes']['tags']).to match_array([ 'updated', 'tags' ])
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        patch "/api/v1/restaurants/#{restaurant.id}",
              params: { restaurant: { rating: 'invalid' } },
              headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
      end
    end

    context 'when an error occurs' do
      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all
        @error_restaurant = create(:restaurant, user: user, name: "Update Error Restaurant #{Time.current.to_f}")
        allow_any_instance_of(RestaurantUpdater).to receive(:update).and_return(false)
        allow_any_instance_of(Restaurant).to receive(:errors).and_return(
          double(full_messages: [ "Failed to update restaurant" ])
        )
      end

      it 'returns an error response' do
        patch "/api/v1/restaurants/#{@error_restaurant.id}",
              params: { restaurant: { name: 'New Name' } },
              headers: @headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'].first['detail']).to eq('Failed to update restaurant')
      end
    end

    context 'when updating with images' do
      let(:image_file) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }

      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all

        # Create a new restaurant
        @restaurant_with_image = create(:restaurant, user: user, name: "Image Test Restaurant #{Time.current.to_f}")
      end

      it 'processes images successfully' do
        expect {
          patch "/api/v1/restaurants/#{@restaurant_with_image.id}",
                params: { restaurant: { name: 'Updated Name', images: [ image_file ] } },
                headers: @headers
        }.to change(@restaurant_with_image.images, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
      end

      context 'when image processing fails' do
        before do
          allow(ActiveRecord::Base).to receive(:transaction).and_raise(StandardError.new("Failed to process image"))
        end

        it 'returns an error response' do
          patch "/api/v1/restaurants/#{@restaurant_with_image.id}",
                params: { restaurant: { name: 'Updated Name', images: [ image_file ] } },
                headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Failed to process image')
        end
      end
    end
  end

  shared_examples 'returns not found error' do |http_method, action_path|
    it 'returns not found error' do
      send(http_method, action_path, headers: @headers)

      expect(response).to have_http_status(:not_found)
      expect(json_response['status']).to eq('error')
      expect(json_response['errors'].first['detail']).to eq('Restaurant not found')
    end
  end

  context 'when restaurant does not exist' do
    let(:non_existent_id) { 999999 }

    describe 'GET /api/v1/restaurants/:id' do
      include_examples 'returns not found error', :get, '/api/v1/restaurants/999999'
    end

    describe 'PATCH /api/v1/restaurants/:id' do
      include_examples 'returns not found error', :patch, '/api/v1/restaurants/999999'
    end

    describe 'DELETE /api/v1/restaurants/:id' do
      include_examples 'returns not found error', :delete, '/api/v1/restaurants/999999'
    end

    describe 'POST /api/v1/restaurants/:id/add_tag' do
      include_examples 'returns not found error', :post, '/api/v1/restaurants/999999/add_tag'
    end

    describe 'DELETE /api/v1/restaurants/:id/remove_tag' do
      include_examples 'returns not found error', :delete, '/api/v1/restaurants/999999/remove_tag'
    end
  end

  describe 'final operations' do
    before(:each) do
      Restaurant.destroy_all
    end

    describe 'POST /api/v1/restaurants/:id/add_tag' do
      before(:each) do
        # Clean up all associated records
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all

        # Create a new restaurant
        @restaurant = create(:restaurant, user: user, name: "Tag Test Restaurant #{Time.current.to_f}")
      end

      it 'adds a tag to the restaurant' do
        post "/api/v1/restaurants/#{@restaurant.id}/add_tag",
             params: { tag: 'newtag' },
             headers: @headers

        expect(response).to have_http_status(:ok)
        expect(@restaurant.reload.tag_list).to include('newtag')
      end

      context 'when an error occurs' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, user: user, name: "Tag Error Restaurant #{Time.current.to_f}")
          allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Failed to save tag"))
        end

        it 'returns an error response' do
          post "/api/v1/restaurants/#{@error_restaurant.id}/add_tag",
               params: { tag: 'newtag' },
               headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Failed to save tag')
        end
      end

      context 'when save fails with validation errors' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, user: user, name: "Tag Validation Error Restaurant #{Time.current.to_f}")
          allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Tag name is invalid")
        end

        it 'returns an error response' do
          post "/api/v1/restaurants/#{@error_restaurant.id}/add_tag",
               params: { tag: 'newtag' },
               headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Tag name is invalid')
        end
      end
    end

    describe 'DELETE /api/v1/restaurants/:id/remove_tag' do
      let(:restaurant) { create(:restaurant, user: user, name: "Remove Tag Restaurant #{Time.current.to_f}") }

      before do
        restaurant.tag_list.add('existingtag')
        restaurant.save
      end

      it 'removes a tag from the restaurant' do
        delete "/api/v1/restaurants/#{restaurant.id}/remove_tag",
               params: { tag: 'existingtag' },
               headers: @headers

        expect(response).to have_http_status(:ok)
        expect(restaurant.reload.tag_list).not_to include('existingtag')
      end

      context 'when an error occurs' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, user: user, name: "Remove Tag Error Restaurant #{Time.current.to_f}")
          @error_restaurant.tag_list.add('existingtag')
          @error_restaurant.save!
          allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Failed to remove tag"))
        end

        it 'returns an error response' do
          delete "/api/v1/restaurants/#{@error_restaurant.id}/remove_tag",
                 params: { tag: 'existingtag' },
                 headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Failed to remove tag')
        end
      end

      context 'when save fails with validation errors' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          CuisineType.destroy_all
          @error_restaurant = create(:restaurant, user: user, name: "Remove Tag Validation Error Restaurant #{Time.current.to_f}")
          @error_restaurant.tag_list.add('existingtag')
          @error_restaurant.save!
          allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Cannot remove protected tag")
        end

        it 'returns an error response' do
          delete "/api/v1/restaurants/#{@error_restaurant.id}/remove_tag",
                 params: { tag: 'existingtag' },
                 headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Cannot remove protected tag')
        end
      end
    end

    describe 'DELETE /api/v1/restaurants/:id' do
      before do
        @restaurant_to_delete = create(:restaurant, user: user, name: "Delete Test Restaurant #{Time.current.to_f}")
      end

      it 'destroys the restaurant' do
        expect {
          delete api_v1_restaurant_path(@restaurant_to_delete), headers: @headers
        }.to change(Restaurant, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(Restaurant.find_by(id: @restaurant_to_delete.id)).to be_nil
      end

      context 'when destroy fails with validation errors' do
        before do
          allow_any_instance_of(Restaurant).to receive(:destroy).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Cannot delete restaurant with existing visits")
        end

        it 'returns an error response' do
          delete api_v1_restaurant_path(@restaurant_to_delete), headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Cannot delete restaurant with existing visits')
        end
      end

      context 'when destroy raises an error' do
        before do
          allow_any_instance_of(Restaurant).to receive(:destroy)
            .and_raise(StandardError.new("Database connection lost during deletion"))
        end

        it 'returns an error response' do
          delete api_v1_restaurant_path(@restaurant_to_delete), headers: @headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to eq('Database connection lost during deletion')
        end
      end
    end
  end
end
