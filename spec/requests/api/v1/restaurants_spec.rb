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
      price_level: 2,
      rating: 4,
      notes: 'Great place!',
      tag_list: 'pasta, wine'
    }
  end

  let(:location_attributes) do
    {
      address: '123 Test St',
      city: 'Test City',
      latitude: 40.7128,
      longitude: -74.0060
    }
  end

  before do
    italian_cuisine # ensure cuisine type exists
    # Use JWT authentication instead of the old sign_in method
    @auth_headers = sign_in_with_token(user)
    Current.organization = organization
  end

  after do
    Current.organization = nil
  end

  describe 'GET /api/v1/restaurants' do
    context 'with no restaurants' do
      it 'returns an empty list' do
        get '/api/v1/restaurants', headers: @auth_headers

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
        puts "\n=== DEBUG: Before request ==="
        puts "Auth headers: #{@auth_headers.inspect}"
        puts "Organization: #{organization.inspect}"
        puts "Current.organization: #{Current.organization.inspect}"
        puts "Restaurants: #{Restaurant.where(organization_id: organization.id).count}"
        
        get '/api/v1/restaurants', headers: @auth_headers
        
        puts "\n=== DEBUG: After request ==="
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
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
          get '/api/v1/restaurants', params: { order_by: 'name', order_direction: 'asc' }.as_json, headers: @auth_headers

          names = json_response['data'].map { |r| r['attributes']['name'] }
          expect(names).to eq(names.sort)
        end

        it 'sorts by created_at' do
          get '/api/v1/restaurants', params: { order_by: 'created_at', order_direction: 'desc' }.as_json, headers: @auth_headers

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
          get '/api/v1/restaurants', params: { tag: 'italian' }.as_json, headers: @auth_headers

          expect(response).to have_http_status(:ok)
          expect(json_response['data'].length).to eq(1)
          expect(json_response['data'].first['attributes']['name']).to eq('Tagged Restaurant')
        end

        it 'filters by search term' do
          puts "\n=== DEBUG: Search Test ==="
          puts "Restaurant names: #{Restaurant.all.pluck(:name)}"
          
          get '/api/v1/restaurants', params: { search: 'Tagged' }.as_json, headers: @auth_headers
          
          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
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
          get '/api/v1/restaurants', params: { latitude: 40.7128, longitude: -74.0060 }.as_json, headers: @auth_headers

          expect(response).to have_http_status(:ok)
          expect(json_response['data'].first['attributes']).to include('distance')
        end
      end

      context 'when an error occurs' do
        before do
          allow_any_instance_of(RestaurantQuery).to receive(:call).and_raise(StandardError.new('Query failed'))
        end

        it 'returns an error response' do
          puts "\n=== DEBUG: GET Error Test ==="
          
          get '/api/v1/restaurants', headers: @auth_headers

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'][0]['detail']).to eq('Query failed')
        end
      end
    end
  end

  describe 'POST /api/v1/restaurants' do
    context 'with valid parameters' do
      it 'creates a new restaurant' do
        puts "\n=== DEBUG: Create Restaurant Test ==="
        puts "Restaurant attributes: #{restaurant_attributes.inspect}"
        puts "Location attributes: #{location_attributes.inspect}"
        puts "Current.organization: #{Current.organization.inspect}"
        
        expect {
          post '/api/v1/restaurants', 
               params: { 
                 restaurant: restaurant_attributes.as_json, 
                 location: location_attributes.as_json 
               }, 
               headers: @auth_headers,
               as: :json
          
          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
        }.to change(Restaurant, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['name']).to eq(restaurant_attributes[:name])
      end

      it 'handles tags' do
        # First create a restaurant without tags
        post '/api/v1/restaurants', 
             params: { 
               restaurant: restaurant_attributes.except(:tag_list).as_json, 
               location: location_attributes.as_json 
             }, 
             headers: @auth_headers,
             as: :json

        expect(response).to have_http_status(:created)
        restaurant_id = json_response['data']['id']
        
        # Then add tags using the add_tag endpoint
        post "/api/v1/restaurants/#{restaurant_id}/add_tag", 
             params: { tag: 'pasta' }.as_json, 
             headers: @auth_headers,
             as: :json
             
        expect(response).to have_http_status(:ok)
        
        post "/api/v1/restaurants/#{restaurant_id}/add_tag", 
             params: { tag: 'wine' }.as_json, 
             headers: @auth_headers,
             as: :json
             
        expect(response).to have_http_status(:ok)
        
        # Reset the json_response cache
        @json_response = nil
        
        # Finally, check that the tags were added
        get "/api/v1/restaurants/#{restaurant_id}", headers: @auth_headers
        
        puts "\n=== DEBUG: Tags Test ==="
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['tags']).to match_array(['pasta', 'wine'])
      end

      context 'with images' do
        let(:image) { fixture_file_upload('spec/fixtures/test_image.jpg', 'image/jpeg') }
        let(:non_image) { fixture_file_upload('spec/fixtures/test.txt', 'text/plain') }

        it 'only processes files with image content type' do
          post '/api/v1/restaurants',
               params: { 
                 restaurant: restaurant_attributes.merge(images: [image, non_image]).as_json, 
                 location: location_attributes.as_json 
               }, 
               headers: @auth_headers,
               as: :json

          expect(response).to have_http_status(:created)
          # Add expectations for image processing based on your implementation
        end
      end

      context 'when creating with rating' do
        it 'creates restaurant with integer rating' do
          puts "\n=== DEBUG: Rating Test ==="
          puts "Auth headers: #{@auth_headers.inspect}"
          puts "Restaurant params: #{restaurant_attributes.merge(rating: '4').inspect}"
          puts "Location params: #{location_attributes.inspect}"
          
          attributes = restaurant_attributes.merge(rating: '4')
          
          post '/api/v1/restaurants', 
               params: { 
                 restaurant: attributes.as_json, 
                 location: location_attributes.as_json 
               }, 
               headers: @auth_headers,
               as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['rating']).to eq(4)
        end
      end

      context 'when creating without rating' do
        it 'creates restaurant with nil rating' do
          puts "\n=== DEBUG: Nil Rating Test ==="
          attributes = restaurant_attributes.merge(rating: nil)
          puts "Restaurant params: #{attributes.inspect}"
          
          post '/api/v1/restaurants', 
               params: { 
                 restaurant: attributes.as_json, 
                 location: location_attributes.as_json 
               }, 
               headers: @auth_headers,
               as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['rating']).to be_nil
        end
      end

      context 'when creating with google_place_id' do
        context 'with different coordinates' do
          it 'creates restaurant with coordinates' do
            attributes = restaurant_attributes.merge(google_place_id: 'test_place_id')
            location = location_attributes.merge(latitude: 41.0, longitude: -75.0)
            
            post '/api/v1/restaurants', 
                 params: { 
                   restaurant: attributes.as_json, 
                   location: location.as_json,
                   google_place_id: 'test_place_id'
                 }, 
                 headers: @auth_headers,
                 as: :json

            expect(response).to have_http_status(:created)
            expect(json_response['data']['attributes']['location']['latitude']).to eq(41.0)
            expect(json_response['data']['attributes']['location']['longitude']).to eq(-75.0)
          end
        end

        context 'with default coordinates' do
          it 'creates restaurant with default coordinates' do
            attributes = restaurant_attributes.merge(google_place_id: 'test_place_id')
            
            post '/api/v1/restaurants', 
                 params: { 
                   restaurant: attributes.as_json, 
                   location: location_attributes.as_json,
                   google_place_id: 'test_place_id'
                 }, 
                 headers: @auth_headers,
                 as: :json

            expect(response).to have_http_status(:created)
            expect(json_response['data']['attributes']['location']['latitude']).to eq(40.7128)
            expect(json_response['data']['attributes']['location']['longitude']).to eq(-74.006)
          end
        end
      end

      context 'when creating without google_place_id' do
        context 'with different coordinates' do
          it 'creates restaurant with coordinates' do
            location = location_attributes.merge(latitude: 41.0, longitude: -75.0)
            
            post '/api/v1/restaurants', 
                 params: { 
                   restaurant: restaurant_attributes.as_json, 
                   location: location.as_json 
                 }, 
                 headers: @auth_headers,
                 as: :json

            expect(response).to have_http_status(:created)
            expect(json_response['data']['attributes']['location']['latitude']).to eq(41.0)
            expect(json_response['data']['attributes']['location']['longitude']).to eq(-75.0)
          end
        end

        context 'with default coordinates' do
          it 'creates restaurant with default coordinates' do
            post '/api/v1/restaurants', 
                 params: { 
                   restaurant: restaurant_attributes.as_json, 
                   location: location_attributes.as_json 
                 }, 
                 headers: @auth_headers,
                 as: :json

            expect(response).to have_http_status(:created)
            expect(json_response['data']['attributes']['location']['latitude']).to eq(40.7128)
            expect(json_response['data']['attributes']['location']['longitude']).to eq(-74.006)
          end
        end
      end

      context 'with google_place_id' do
        it 'converts string coordinates to decimal' do
          location = location_attributes.merge(latitude: '41.0', longitude: '-75.0')
          
          post '/api/v1/restaurants', 
               params: { 
                 restaurant: restaurant_attributes.as_json, 
                 location: location.as_json,
                 google_place_id: 'test_place_id'
               }, 
               headers: @auth_headers,
               as: :json

          expect(response).to have_http_status(:created)
          expect(json_response['data']['attributes']['location']['latitude']).to eq(41.0)
          expect(json_response['data']['attributes']['location']['longitude']).to eq(-75.0)
        end

        it 'returns validation error for invalid coordinates' do
          puts "\n=== DEBUG: Invalid Coordinates Test ==="
          location = location_attributes.merge(latitude: 'invalid', longitude: 'invalid')
          puts "Location params: #{location.inspect}"
          
          post '/api/v1/restaurants', 
               params: { 
                 restaurant: restaurant_attributes.as_json, 
                 location: location.as_json,
                 google_place_id: 'test_place_id'
               }, 
               headers: @auth_headers,
               as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'].first['detail']).to include('Latitude is not a number')
        end
      end
    end

    context 'with invalid parameters' do
      it 'returns error messages' do
        puts "\n=== DEBUG: Invalid Parameters Test ==="
        
        post '/api/v1/restaurants', 
             params: { 
               restaurant: { name: '', cuisine_type_name: 'american' }.as_json, 
               location: location_attributes.as_json 
             }, 
             headers: @auth_headers,
             as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to include("Name can't be blank")
      end

      it 'returns error when restaurant params are missing' do
        puts "\n=== DEBUG: Missing Restaurant Params Test ==="
        
        post '/api/v1/restaurants', 
             params: { 
               location: location_attributes.as_json 
             }, 
             headers: @auth_headers,
             as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'].first['detail']).to include('param is missing or the value is empty')
      end

      it 'filters out unpermitted parameters' do
        puts "\n=== DEBUG: Unpermitted Parameters Test ==="
        attributes = restaurant_attributes.merge(unpermitted: 'value')
        puts "Restaurant params: #{attributes.inspect}"
        
        post '/api/v1/restaurants', 
             params: { 
               restaurant: attributes.as_json, 
               location: location_attributes.as_json 
             }, 
             headers: @auth_headers,
             as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:created)
        restaurant = Restaurant.last
        expect(restaurant).not_to respond_to(:unpermitted)
      end
    end

    context 'when an error occurs' do
      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        CuisineType.destroy_all  # Make sure to destroy ALL cuisine types

        # Create only one cuisine type to ensure others are invalid
        create(:cuisine_type, name: 'american')
        
        puts "\n=== DEBUG: Available Cuisine Types ==="
        puts "Available types: #{CuisineType.pluck(:name).join(', ')}"
        
        # Mock the validate_cuisine_type method to always return an error for 'non_existent_cuisine_type'
        allow_any_instance_of(Api::V1::RestaurantsController).to receive(:validate_cuisine_type)
          .with('non_existent_cuisine_type')
          .and_return([false, "Invalid cuisine type: non_existent_cuisine_type. Available types: american"])
      end

      it 'returns an error response for invalid cuisine type' do
        puts "\n=== DEBUG: Error Response Test ==="
        puts "Restaurant params: #{restaurant_attributes.inspect}"
        puts "Location params: #{location_attributes.inspect}"
        
        # Use a completely non-existent cuisine type
        invalid_attributes = restaurant_attributes.merge(cuisine_type_name: 'non_existent_cuisine_type')
        puts "Using invalid cuisine type: #{invalid_attributes[:cuisine_type_name]}"
        
        post '/api/v1/restaurants', 
             params: { 
               restaurant: invalid_attributes.as_json, 
               location: location_attributes.as_json 
             }, 
             headers: @auth_headers,
             as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to include('Invalid cuisine type: non_existent_cuisine_type')
      end
    end
  end

  describe 'when restaurant does not exist' do
    context 'GET /api/v1/restaurants/:id' do
      it 'returns not found error' do
        non_existent_id = 999999
        get "/api/v1/restaurants/#{non_existent_id}", headers: @auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to eq('Restaurant not found')
      end
    end

    context 'PATCH /api/v1/restaurants/:id' do
      it 'returns not found error' do
        puts "\n=== DEBUG: PATCH Not Found Test ==="
        
        non_existent_id = 999999
        patch "/api/v1/restaurants/#{non_existent_id}", 
              params: { 
                restaurant: restaurant_attributes.as_json, 
                location: location_attributes.as_json 
              }, 
              headers: @auth_headers,
              as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to eq('Restaurant not found')
      end
    end

    context 'DELETE /api/v1/restaurants/:id' do
      it 'returns not found error' do
        non_existent_id = 999999
        delete "/api/v1/restaurants/#{non_existent_id}", headers: @auth_headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to eq('Restaurant not found')
      end
    end

    context 'POST /api/v1/restaurants/:id/add_tag' do
      it 'returns not found error' do
        puts "\n=== DEBUG: Add Tag Not Found Test ==="
        
        non_existent_id = 999999
        
        post "/api/v1/restaurants/#{non_existent_id}/add_tag", 
             params: { tag: 'newtag' }.as_json, 
             headers: @auth_headers,
             as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to eq('Restaurant not found')
      end
    end

    context 'DELETE /api/v1/restaurants/:id/remove_tag' do
      it 'returns not found error' do
        puts "\n=== DEBUG: Remove Tag Not Found Test ==="
        
        non_existent_id = 999999
        
        delete "/api/v1/restaurants/#{non_existent_id}/remove_tag", 
               params: { tag: 'existingtag' }.as_json, 
               headers: @auth_headers,
               as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors'][0]['detail']).to eq('Restaurant not found')
      end
    end
  end

  describe 'final operations' do
    describe 'POST /api/v1/restaurants/:id/add_tag' do
      before do
        Restaurant.destroy_all
        GoogleRestaurant.destroy_all
        
        # Ensure cuisine types exist
        italian_cuisine # ensure italian cuisine type exists
        
        # Create a new restaurant
        @restaurant = create(:restaurant, organization: organization, name: "Tag Test Restaurant #{Time.current.to_f}", cuisine_type: italian_cuisine)
      end

      it 'adds a tag to the restaurant' do
        puts "\n=== DEBUG: Add Tag Test ==="
        puts "Restaurant ID: #{@restaurant.id}"
        puts "Auth headers: #{@auth_headers.inspect}"
        
        post "/api/v1/restaurants/#{@restaurant.id}/add_tag", 
             params: { tag: 'newtag' }.as_json, 
             headers: @auth_headers,
             as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['tags']).to include('newtag')
      end

      context 'when an error occurs' do
        before do
          # Create a restaurant with a unique name
          @error_restaurant = create(:restaurant, 
                                    organization: organization, 
                                    name: "Tag Error Restaurant #{Time.current.to_i}#{rand(1000)}",
                                    cuisine_type: italian_cuisine)
          allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Failed to save tag"))
        end

        it 'returns an error response' do
          puts "\n=== DEBUG: Add Tag Error Test ==="
          puts "Restaurant ID: #{@error_restaurant.id}"
          
          post "/api/v1/restaurants/#{@error_restaurant.id}/add_tag", 
               params: { tag: 'newtag' }.as_json, 
               headers: @auth_headers,
               as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'][0]['detail']).to eq('Failed to save tag')
        end
      end

      context 'when save fails with validation errors' do
        before do
          # Create a restaurant with a unique name
          @error_restaurant = create(:restaurant, 
                                    organization: organization, 
                                    name: "Tag Validation Error Restaurant #{Time.current.to_i}#{rand(1000)}",
                                    cuisine_type: italian_cuisine)
          allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Tag validation failed")
        end

        it 'returns an error response' do
          puts "\n=== DEBUG: Add Tag Validation Error Test ==="
          puts "Restaurant ID: #{@error_restaurant.id}"
          
          post "/api/v1/restaurants/#{@error_restaurant.id}/add_tag", 
               params: { tag: 'newtag' }.as_json, 
               headers: @auth_headers,
               as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'][0]['detail']).to eq('Tag validation failed')
        end
      end
    end

    describe 'DELETE /api/v1/restaurants/:id/remove_tag' do
      let(:restaurant) do
        # Use a unique name with a timestamp to avoid conflicts
        create(:restaurant, 
              organization: organization, 
              name: "Remove Tag Restaurant #{Time.current.to_i}#{rand(1000)}", 
              cuisine_type: italian_cuisine)
      end

      before do
        # Add a tag to the restaurant
        restaurant.tag_list.add('existingtag')
        restaurant.save!
        puts "\n=== DEBUG: Remove Tag Test ==="
        puts "Restaurant ID: #{restaurant.id}"
        puts "Restaurant name: #{restaurant.name}"
        puts "Tags before: #{restaurant.tag_list.inspect}"
      end

      it 'removes a tag from the restaurant' do
        delete "/api/v1/restaurants/#{restaurant.id}/remove_tag", 
               params: { tag: 'existingtag' }.as_json, 
               headers: @auth_headers,
               as: :json

        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"
        
        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('success')
        expect(json_response['data']['attributes']['tags']).not_to include('existingtag')
      end

      context 'when an error occurs' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          @error_restaurant = create(:restaurant, organization: organization, name: "Remove Tag Error Restaurant #{Time.current.to_f}")
          @error_restaurant.tag_list.add('existingtag')
          @error_restaurant.save!
          allow_any_instance_of(Restaurant).to receive(:save).and_raise(StandardError.new("Failed to remove tag"))
        end

        it 'returns an error response' do
          puts "\n=== DEBUG: Remove Tag Error Test ==="
          puts "Restaurant ID: #{@error_restaurant.id}"
          
          delete "/api/v1/restaurants/#{@error_restaurant.id}/remove_tag", 
                 params: { tag: 'existingtag' }.as_json, 
                 headers: @auth_headers,
                 as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'][0]['detail']).to eq('Failed to remove tag')
        end
      end

      context 'when save fails with validation errors' do
        before do
          Restaurant.destroy_all
          GoogleRestaurant.destroy_all
          @error_restaurant = create(:restaurant, organization: organization, name: "Remove Tag Validation Error Restaurant #{Time.current.to_f}")
          @error_restaurant.tag_list.add('existingtag')
          @error_restaurant.save!
          allow_any_instance_of(Restaurant).to receive(:save).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Tag removal failed")
        end

        it 'returns an error response' do
          puts "\n=== DEBUG: Remove Tag Validation Error Test ==="
          puts "Restaurant ID: #{@error_restaurant.id}"
          
          delete "/api/v1/restaurants/#{@error_restaurant.id}/remove_tag", 
                 params: { tag: 'existingtag' }.as_json, 
                 headers: @auth_headers,
                 as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'][0]['detail']).to eq('Tag removal failed')
        end
      end
    end

    describe 'DELETE /api/v1/restaurants/:id' do
      context 'when destroy fails with validation errors' do
        before do
          # Create a restaurant with a unique name
          @error_restaurant = create(:restaurant, 
                                    organization: organization, 
                                    name: "Delete Error Restaurant #{Time.current.to_i}#{rand(1000)}",
                                    cuisine_type: italian_cuisine)
          allow_any_instance_of(Restaurant).to receive(:destroy).and_return(false)
          allow_any_instance_of(Restaurant).to receive_message_chain(:errors, :full_messages, :join)
            .and_return("Cannot delete restaurant")
        end

        it 'returns an error response' do
          puts "\n=== DEBUG: Delete Error Test ==="
          puts "Restaurant ID: #{@error_restaurant.id}"
          
          delete "/api/v1/restaurants/#{@error_restaurant.id}", 
                 headers: @auth_headers,
                 as: :json

          puts "Response status: #{response.status}"
          puts "Response body: #{response.body}"
          
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['status']).to eq('error')
          expect(json_response['errors'][0]['detail']).to eq('Cannot delete restaurant')
        end
      end
    end
  end
end
