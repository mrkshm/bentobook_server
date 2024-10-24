require 'rails_helper'

RSpec.describe RestaurantManagement do
  let(:test_class) do
    Class.new do
      include RestaurantManagement
      attr_accessor :params, :current_user, :request

      def initialize(params, current_user, request)
        @params = params
        @current_user = current_user
        @request = request
        @restaurant_params = params[:restaurant]
      end

      def render(*args); end
      def flash; {}; end
      def redirect_to(*args); end
      def restaurants_path; '/restaurants'; end

      # Make private methods public for testing
      public :set_restaurant, :build_restaurant, :compare_and_save_restaurant,
             :google_restaurant_params, :restaurant_params, :restaurant_save_params,
             :restaurant_update_params, :find_or_create_google_restaurant
    end
  end

  let(:user) { create_list(:user, 1).first }
  let(:request) { double('request', format: double('format')) }
  let(:instance) { test_class.new(params, user, request) }

  describe "#restaurant_params" do
    it "permits the correct parameters" do
      params = ActionController::Parameters.new(
        restaurant: {
          name: "Test Restaurant",
          address: "123 Test St",
          cuisine_type: "Italian",
          rating: 4,
          price_level: 2,
          google_place_id: "123",
          city: "Test City",
          latitude: 40.7128,
          longitude: -74.0060
        }
      )
      
      instance = test_class.new(params, user, request)
      permitted_params = instance.restaurant_params
      
      expect(permitted_params).to include(:name, :address, :cuisine_type, :rating, :price_level, :google_place_id, :city, :latitude, :longitude)
    end
  end

  describe "#restaurant_update_params" do
    it "permits the correct parameters" do
      params = ActionController::Parameters.new(
        restaurant: {
          name: "Updated Restaurant",
          address: "456 Update St",
          cuisine_type_name: "Italian",
          rating: 5,
          price_level: 3,
          tag_list: "tag1, tag2",
          images: []
        }
      )
      
      instance = test_class.new(params, user, request)
      permitted_params = instance.restaurant_update_params
      
      expect(permitted_params).to include(:name, :address, :cuisine_type_name, :rating, :price_level, :tag_list)
      expect(permitted_params[:images]).to eq([])
    end
  end

  describe '#set_restaurant' do
    let(:restaurant) { create(:restaurant, user: user) }
    let(:params) { ActionController::Parameters.new(id: restaurant.id) }

    it 'sets the restaurant for the current user' do
      allow(user.restaurants).to receive(:with_google).and_return(user.restaurants)
      expect(instance.set_restaurant).to eq(restaurant)
    end

    context 'when restaurant is not found' do
      let(:params) { ActionController::Parameters.new(id: 'non_existent') }

      before do
        allow(instance).to receive(:restaurants_path).and_return('/restaurants')
      end

      it 'handles JSON format' do
        allow(request.format).to receive(:json?).and_return(true)
        expect(instance).to receive(:render).with(json: { error: "Restaurant not found or you don't have permission to view it" }, status: :not_found)
        instance.set_restaurant
      end

      it 'handles HTML format' do
        allow(request.format).to receive(:json?).and_return(false)
        expect(instance).to receive(:flash).and_return({})
        expect(instance).to receive(:redirect_to).with('/restaurants')
        instance.set_restaurant
      end
    end
  end

  describe '#build_restaurant' do
    let(:params) do
      ActionController::Parameters.new(
        restaurant: {
          name: 'Test Restaurant',
          address: '123 Test St',
          images: []
        }
      )
    end

    it 'builds a new restaurant without images' do
      restaurant = instance.build_restaurant
      expect(restaurant).to be_a(Restaurant)
      expect(restaurant.images).to be_empty
    end

    context 'with images' do
      let(:image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      
      before do
        params[:restaurant][:images] = [image]
      end

      it 'builds a new restaurant with images' do
        restaurant = instance.build_restaurant
        expect(restaurant).to be_a(Restaurant)
        expect(restaurant.name).to eq('Test Restaurant')
        expect(restaurant.images.size).to eq(1)
        expect(restaurant.images.first).to be_new_record
        expect(restaurant.images.first.file).to be_attached
      end
    end
  end

  describe '#compare_and_save_restaurant' do
    let(:restaurant) { create(:restaurant, user: user) }
    let(:google_restaurant) { create(:google_restaurant, name: 'Google Name', address: 'Google Address') }
    let(:params) do
      ActionController::Parameters.new(
        restaurant: {
          name: 'Updated Name',
          address: 'Updated Address',
          rating: 4,
          price_level: 3,
          notes: 'Updated Notes',
          cuisine_type_id: 2
        }
      )
    end
    
    before do
      restaurant.google_restaurant = google_restaurant
      instance.instance_variable_set(:@restaurant, restaurant)
      allow(instance).to receive(:restaurant_params).and_return(params[:restaurant])
    end

    it 'compares and saves restaurant attributes' do
      instance.compare_and_save_restaurant

      expect(restaurant.name).to eq('Updated Name')
      expect(restaurant.address).to eq('Updated Address')
      expect(restaurant.rating).to eq(4)
      expect(restaurant.price_level).to eq(3)
      expect(restaurant.notes).to eq('Updated Notes')
      expect(restaurant.cuisine_type_id).to eq(2)
    end

    it 'uses Google values when user values are not present' do
      params[:restaurant].delete(:name)
      params[:restaurant].delete(:address)
      instance.compare_and_save_restaurant

      expect(restaurant.name).to eq('Google Name')
      expect(restaurant.address).to eq('Google Address')
    end

    it 'saves the restaurant' do
      expect(restaurant).to receive(:save)
      instance.compare_and_save_restaurant
    end
  end

  describe '#google_restaurant_params' do
    it 'permits the correct parameters' do
      params = ActionController::Parameters.new(
        restaurant: {
          google_restaurant_attributes: {
            id: 1,
            google_place_id: 'abc123',
            name: 'Google Restaurant',
            address: '123 Google St',
            city: 'Google City',
            state: 'GS',
            country: 'Googleland',
            latitude: 40.7128,
            longitude: -74.0060,
            street_number: '123',
            street: 'Google St',
            postal_code: '12345',
            phone_number: '123-456-7890',
            url: 'https://google.com',
            business_status: 'OPERATIONAL',
            price_level: 2
          }
        }
      )
      
      instance = test_class.new(params, user, request)
      permitted_params = instance.google_restaurant_params
      
      expect(permitted_params).to include(
        :id, :google_place_id, :name, :address, :city, :state, :country,
        :latitude, :longitude, :street_number, :street, :postal_code,
        :phone_number, :url, :business_status, :price_level
      )
    end
  end

  describe '#restaurant_save_params' do
    it 'permits the correct parameters' do
      params = ActionController::Parameters.new(
        restaurant: {
          name: 'Test Restaurant',
          address: '123 Test St',
          notes: 'Test Notes',
          cuisine_type_id: 1,
          rating: 4,
          price_level: 2,
          google_restaurant_attributes: {
            id: 1,
            google_place_id: 'abc123',
            name: 'Google Restaurant'
          },
          images: []
        }
      )
      
      instance = test_class.new(params, user, request)
      permitted_params = instance.restaurant_save_params
      
      expect(permitted_params).to include(:name, :address, :notes, :cuisine_type_id, :rating, :price_level)
      expect(permitted_params[:google_restaurant_attributes]).to include(:id, :google_place_id, :name)
      expect(permitted_params[:images]).to eq([])
    end
  end

  describe '#find_or_create_google_restaurant' do
    let(:params) do
      {
        restaurant: {
          name: 'Test Restaurant',
          address: '123 Test St',
          city: 'Test City',
          latitude: 40.7128,
          longitude: -74.0060,
          google_place_id: 'abc123'
        }
      }
    end

    before do
      allow(instance).to receive(:restaurant_params).and_return(params[:restaurant])
    end

    context 'when google_place_id exists' do
      it 'finds the existing GoogleRestaurant' do
        existing_restaurant = create(:google_restaurant, google_place_id: 'abc123', name: 'Existing Name')
        
        expect(Rails.logger).to receive(:info).with(/GoogleRestaurant after find_or_create_by:/)

        result = instance.find_or_create_google_restaurant
        expect(result).to eq(existing_restaurant)
        expect(result.name).to eq('Existing Name')  # It should not update the name
      end
    end

    context 'when google_place_id does not exist' do
      it 'creates a new GoogleRestaurant' do
        expect {
          instance.find_or_create_google_restaurant
        }.to change(GoogleRestaurant, :count).by(1)
      end
    end

    context 'when latitude or longitude is missing' do
      let(:params) do
        {
          restaurant: {
            name: 'Test Restaurant',
            address: '123 Test St',
            city: 'Test City',
            google_place_id: 'abc123'
          }
        }
      end

      it 'raises an error' do
        expect {
          instance.find_or_create_google_restaurant
        }.to raise_error(ArgumentError, "Latitude or longitude is required")
      end
    end

    context 'when google_place_id is missing' do
      let(:params) do
        {
          restaurant: {
            name: 'Test Restaurant',
            address: '123 Test St',
            city: 'Test City',
            latitude: 40.7128,
            longitude: -74.0060
          }
        }
      end

      it 'returns nil' do
        expect(instance.find_or_create_google_restaurant).to be_nil
      end
    end

    context 'when GoogleRestaurant fails to create' do
      before do
        allow(GoogleRestaurant).to receive(:find_or_create_by).and_return(GoogleRestaurant.new)
        allow_any_instance_of(GoogleRestaurant).to receive(:persisted?).and_return(false)
      end

      it 'does not increase the GoogleRestaurant count' do
        expect {
          instance.find_or_create_google_restaurant
        }.not_to change(GoogleRestaurant, :count)
      end
    end

    context 'when GoogleRestaurant is invalid' do
      let(:invalid_google_restaurant) { GoogleRestaurant.new }
      
      before do
        allow(GoogleRestaurant).to receive(:find_or_create_by).and_return(invalid_google_restaurant)
        allow(invalid_google_restaurant).to receive(:valid?).and_return(false)
        allow(invalid_google_restaurant).to receive(:errors).and_return(
          double(full_messages: ['Error message'])
        )
      end

      it 'logs an error message with validation errors' do
        expect(Rails.logger).to receive(:warn).with(/GoogleRestaurant is invalid:/)

        instance.find_or_create_google_restaurant
      end
    end
  end
end
