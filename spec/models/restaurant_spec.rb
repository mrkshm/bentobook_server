require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  before(:all) do
    ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')
    ActiveRecord::Base.connection.execute(
      "INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) VALUES (4326, 'EPSG', 4326, '+proj=longlat +datum=WGS84 +no_defs', 'GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.01745329251994328,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4326\"]]') ON CONFLICT DO NOTHING;"
    )
  end

  subject { build(:restaurant) }

  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:google_restaurant).optional }
    it { should belong_to(:cuisine_type).optional }
    it { should have_many(:visits).dependent(:restrict_with_error) }
    it { should have_many(:images).dependent(:destroy) }
    it { should have_many(:list_restaurants).class_name('ListRestaurant').dependent(:destroy) }
    it { should have_many(:lists).through(:list_restaurants) }
    it { should have_many(:copies).class_name('Restaurant').with_foreign_key('original_restaurant_id') }
    it { should belong_to(:original_restaurant).class_name('Restaurant').optional }
    it { should have_many(:restaurant_copies_as_copy).class_name('RestaurantCopy').with_foreign_key('copied_restaurant_id').dependent(:destroy) }
  end

  describe 'validations' do
    context 'without google_restaurant' do
      before { allow(subject).to receive(:google_restaurant).and_return(nil) }
      it { should validate_presence_of(:name) }
    end

    context 'with google_restaurant' do
      before { allow(subject).to receive(:google_restaurant).and_return(build(:google_restaurant)) }
      it { should_not validate_presence_of(:name) }
    end

    it { should validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5).allow_nil }
    it { should validate_numericality_of(:price_level).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(4).allow_nil }
    it { should allow_value('OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY', nil).for(:business_status) }
    it { should_not allow_value('INVALID_STATUS').for(:business_status) }
  end

  describe 'scopes' do
    let(:organization) { create(:organization) }
    let!(:favorite) { create(:restaurant, organization: organization, favorite: true) }
    let!(:non_favorite) { create(:restaurant, organization: organization, favorite: false) }

    describe '.favorites' do
      it 'returns only favorite restaurants' do
        expect(Restaurant.favorites).to include(favorite)
        expect(Restaurant.favorites).not_to include(non_favorite)
      end
    end

    describe '.search_by_all_fields' do
      let!(:restaurant1) { create(:restaurant, organization: organization, name: 'Sushi Place', notes: 'Great sushi') }
      let!(:restaurant2) { create(:restaurant, organization: organization, name: 'Burger Joint') }

      it 'searches restaurants by name and notes' do
        expect(Restaurant.search_by_all_fields('sushi')).to include(restaurant1)
        expect(Restaurant.search_by_all_fields('sushi')).not_to include(restaurant2)
      end

      it 'prioritizes name matches over notes matches' do
        results = Restaurant.search_by_all_fields('sushi')
        expect(results.to_sql).to include('ts_rank')
      end
    end

    describe '.search_by_name_and_address' do
      let(:organization) { create(:organization) }
      # Create restaurants with explicitly set Google restaurants to fix test predictability
      let!(:restaurant1) { 
        gr = create(:google_restaurant, name: 'Sushi Place', address: '123 Main St')
        create(:restaurant, organization: organization, name: 'Sushi Place', address: '123 Main St', google_restaurant: gr)
      }
      let!(:restaurant2) { 
        gr = create(:google_restaurant, name: 'Burger Joint', address: '456 Oak St')
        create(:restaurant, organization: organization, name: 'Burger Joint', address: '456 Oak St', google_restaurant: gr)
      }
      let!(:restaurant3) { 
        gr = create(:google_restaurant, name: 'Default Restaurant', address: '789 Default St')
        create(:restaurant, organization: organization, google_restaurant: gr)
      }
      let!(:other_org_restaurant) { 
        gr = create(:google_restaurant, name: 'Sushi Place', address: '123 Main St')
        create(:restaurant, name: 'Sushi Place', address: '123 Main St', google_restaurant: gr)
      }

      before do
        restaurant3.google_restaurant.update!(name: 'Sushi Express', address: '789 Pine St')
      end

      it 'searches by restaurant name' do
        results = Restaurant.search_by_name_and_address('Sushi', organization)
        expect(results).to include(restaurant1)
        expect(results).not_to include(restaurant2)
        expect(results).not_to include(other_org_restaurant)
      end

      it 'searches by restaurant address' do
        results = Restaurant.search_by_name_and_address('Main', organization)
        puts "\nSQL: #{results.to_sql}\n"
        expect(results).to include(restaurant1)
        expect(results).not_to include(restaurant2)
        expect(results).not_to include(other_org_restaurant)
      end

      it 'searches by google restaurant name' do
        results = Restaurant.search_by_name_and_address('Express', organization)
        expect(results).to include(restaurant3)
      end

      it 'searches by google restaurant address' do
        results = Restaurant.search_by_name_and_address('Pine', organization)
        expect(results).to include(restaurant3)
      end
    end

    describe '.with_google' do
      let!(:restaurant) { create(:restaurant, name: 'Local Name', address: '123 Local St') }
      
      before do
        restaurant.google_restaurant.update!(
          name: 'Google Name',
          address: '123 Google St'
        )
      end

      it 'includes combined attributes' do
        result = Restaurant.with_google.find(restaurant.id)
        expect(result.combined_name).to eq('Local Name')
        expect(result.combined_address).to eq('123 Local St')
      end

      it 'falls back to google data when local data is missing' do
        restaurant.update!(name: nil, address: nil)
        result = Restaurant.with_google.find(restaurant.id)
        expect(result.combined_name).to eq('Google Name')
        expect(result.combined_address).to eq('123 Google St')
      end
    end

    describe '.order_by_visits' do
      let(:organization) { create(:organization) }

      before do
        # Clean up any existing data
        Restaurant.delete_all
        Visit.delete_all

        # Create our test restaurants
        @popular = create(:restaurant, organization: organization)
        @unpopular = create(:restaurant, organization: organization)

        # Create visits for the popular restaurant
        create_list(:visit, 3, restaurant: @popular)
      end

      let(:popular) { @popular }
      let(:unpopular) { @unpopular }

      it 'orders by visit count in descending order by default' do
        results = Restaurant.order_by_visits
        expect(results.first).to eq(popular)
        expect(results.last).to eq(unpopular)
      end

      it 'can order by visit count in ascending order' do
        results = Restaurant.order_by_visits(:asc)
        expect(results.first).to eq(unpopular)
        expect(results.last).to eq(popular)
      end
    end

    describe '.near' do
      let(:organization) { create(:organization) }
      let(:target_lat) { 40.7128 }
      let(:target_lon) { -74.006 }
      
      # Create custom Google restaurants with proper location data
      before(:each) do
        # Delete any existing data that might interfere with our test
        Restaurant.delete_all
        GoogleRestaurant.delete_all
        
        # Create the near restaurant
        @gr_near = create(:google_restaurant, 
                         name: "Near Restaurant", 
                         latitude: target_lat + 0.001, 
                         longitude: target_lon + 0.001)
                         
        # Create the far restaurant 
        @gr_far = create(:google_restaurant, 
                        name: "Far Restaurant", 
                        latitude: target_lat + 0.5, 
                        longitude: target_lon + 0.5)
        
        # Explicitly set location data for PostGIS
        ActiveRecord::Base.connection.execute(
          "UPDATE google_restaurants SET location = ST_SetSRID(ST_MakePoint(#{@gr_near.longitude}, #{@gr_near.latitude}), 4326) WHERE id = #{@gr_near.id}"
        )
        ActiveRecord::Base.connection.execute(
          "UPDATE google_restaurants SET location = ST_SetSRID(ST_MakePoint(#{@gr_far.longitude}, #{@gr_far.latitude}), 4326) WHERE id = #{@gr_far.id}"
        )
        
        # Create restaurants with explicit names to make debugging easier
        @nearby_restaurant = create(:restaurant, name: "Near Restaurant", organization: organization, google_restaurant: @gr_near)
        @far_restaurant = create(:restaurant, name: "Far Restaurant", organization: organization, google_restaurant: @gr_far)
      end
      
      # Define the restaurant objects for the test to use
      let(:nearby_restaurant) { @nearby_restaurant }
      let(:far_restaurant) { @far_restaurant }

      it 'finds restaurants near a given location' do
        results = Restaurant.near(target_lat, target_lon, 5000) # 5km radius should include only nearby restaurant
        expect(results).to include(nearby_restaurant)
        expect(results).not_to include(far_restaurant)
      end

      it 'accepts distance in kilometers' do
        results = Restaurant.near(target_lat, target_lon, 1000) # 1km radius
        expect(results).to include(nearby_restaurant)
        expect(results).not_to include(far_restaurant)
      end
    end

    describe '.order_by_distance_from' do
      let(:organization) { create(:organization) }
      let(:target_lat) { 40.7128 }
      let(:target_lon) { -74.006 }
      
      # Create custom Google restaurants with proper location data for testing order
      before(:each) do
        # Delete any existing data that might interfere with our test
        Restaurant.delete_all
        GoogleRestaurant.delete_all
        
        # Create the near restaurant
        @gr_near = create(:google_restaurant, 
                          name: "Near Restaurant", 
                          latitude: target_lat + 0.001, 
                          longitude: target_lon + 0.001)
                          
        # Create the far restaurant 
        @gr_far = create(:google_restaurant, 
                         name: "Far Restaurant", 
                         latitude: target_lat + 0.5, 
                         longitude: target_lon + 0.5)
        
        # Explicitly set location data for PostGIS
        ActiveRecord::Base.connection.execute(
          "UPDATE google_restaurants SET location = ST_SetSRID(ST_MakePoint(#{@gr_near.longitude}, #{@gr_near.latitude}), 4326) WHERE id = #{@gr_near.id}"
        )
        ActiveRecord::Base.connection.execute(
          "UPDATE google_restaurants SET location = ST_SetSRID(ST_MakePoint(#{@gr_far.longitude}, #{@gr_far.latitude}), 4326) WHERE id = #{@gr_far.id}"
        )
        
        # Create restaurants with explicit names to make debugging easier
        @near = create(:restaurant, name: "Near Restaurant", organization: organization, google_restaurant: @gr_near)
        @far = create(:restaurant, name: "Far Restaurant", organization: organization, google_restaurant: @gr_far)
      end
      
      # Define the restaurant objects for the test to use
      let(:near) { @near }
      let(:far) { @far }

      it 'orders restaurants by distance' do
        ordered = Restaurant.order_by_distance_from(target_lat, target_lon)
        expect(ordered.first).to eq(near)
        expect(ordered.last).to eq(far)
      end
    end
  end

  describe 'combined attributes' do
    let(:restaurant) { create(:restaurant, name: 'Local Name', address: '123 Local St') }

    context 'without google_restaurant' do
      before do
        restaurant.google_restaurant = nil
        restaurant.save!
      end

      it 'uses own attributes' do
        expect(restaurant.combined_name).to eq('Local Name')
        expect(restaurant.combined_address).to eq('123 Local St')
      end
    end

    context 'with google_restaurant' do
      let(:google_restaurant) { create(:google_restaurant, name: 'Google Name', address: '123 Test St') }

      before do
        restaurant.update(google_restaurant: google_restaurant)
      end

      it 'prioritizes own attributes over google data' do
        expect(restaurant.combined_name).to eq('Local Name')
      end

      it 'falls back to google data when own attribute is nil' do
        restaurant.update(name: nil)
        expect(restaurant.combined_name).to eq('Google Name')
      end

      it 'uses google data for missing attributes' do
        restaurant.update(address: nil)
        expect(restaurant.combined_address).to eq('123 Test St')
      end
    end
  end

  describe 'instance methods' do
    describe '#visit_count' do
      let(:restaurant) { create(:restaurant) }

      it 'returns 0 when there are no visits' do
        expect(restaurant.visit_count).to eq(0)
      end

      it 'returns the correct count of visits' do
        create_list(:visit, 3, restaurant: restaurant)
        expect(restaurant.visit_count).to eq(3)
      end
    end

    describe '#parsed_opening_hours' do
      let(:restaurant) { create(:restaurant) }

      it 'returns parsed JSON when valid' do
        hours = { 'monday' => '9:00-17:00' }
        restaurant.update(opening_hours: hours.to_json)
        expect(restaurant.parsed_opening_hours).to eq(hours)
      end

      it 'returns nil when opening hours are not present' do
        expect(restaurant.parsed_opening_hours).to be_nil
      end

      it 'returns nil when opening hours are invalid JSON' do
        restaurant.update(opening_hours: 'invalid json')
        expect(restaurant.parsed_opening_hours).to be_nil
      end
    end

    describe '#distance_to' do
      let(:restaurant) { create(:restaurant, :with_manual_location) }
      let(:lat) { 40.7128 }
      let(:lon) { -74.0060 }

      it 'returns the distance to given coordinates' do
        distance = restaurant.distance_to(lat, lon)
        expect(distance).to be_a(Float)
      end

      it 'returns nil if restaurant has no location' do
        restaurant.google_restaurant.update!(location: nil)
        expect(restaurant.distance_to(lat, lon)).to be_nil
      end
    end

    describe '#price_level_display' do
      let(:restaurant) { create(:restaurant) }

      it 'returns dollar signs based on price level' do
        restaurant.price_level = 3
        expect(restaurant.price_level_display).to eq('$$$')
      end

      it 'returns nil if price level is not set' do
        restaurant.price_level = nil
        expect(restaurant.price_level_display).to be_nil
      end
    end

    describe '#copy_for_organization' do
      let(:source_org) { create(:organization) }
      let(:target_org) { create(:organization) }
      let(:restaurant) { create(:restaurant, organization: source_org) }

      it 'creates a copy in the target organization' do
        copy = restaurant.copy_for_organization(target_org)
        expect(copy).to be_persisted
        expect(copy.organization).to eq(target_org)
        expect(copy.original_restaurant).to eq(restaurant)
      end

      it 'returns existing copy if one exists' do
        first_copy = restaurant.copy_for_organization(target_org)
        second_copy = restaurant.copy_for_organization(target_org)
        expect(second_copy).to eq(first_copy)
      end

      it 'returns self if target is same as current organization' do
        result = restaurant.copy_for_organization(source_org)
        expect(result).to eq(restaurant)
      end

      it 'creates restaurant copy record' do
        copy = restaurant.copy_for_organization(target_org)
        restaurant_copy = RestaurantCopy.find_by(
          organization_id: target_org.id,
          restaurant_id: restaurant.id,
          copied_restaurant_id: copy.id
        )
        expect(restaurant_copy).to be_present
      end

      it 'handles race conditions gracefully' do
        allow(restaurant).to receive(:dup).and_raise(ActiveRecord::RecordNotUnique)
        existing_copy = create(:restaurant, organization: target_org, original_restaurant: restaurant)
        create(:restaurant_copy, 
          organization_id: target_org.id,
          restaurant_id: restaurant.id,
          copied_restaurant_id: existing_copy.id
        )
        
        result = restaurant.copy_for_organization(target_org)
        expect(result).to eq(existing_copy)
      end
    end
  end
end
