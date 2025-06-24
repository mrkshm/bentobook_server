# == Schema Information
#
# Table name: google_restaurants
#
#  id                   :bigint           not null, primary key
#  address              :text
#  business_status      :string
#  city                 :string
#  country              :string
#  google_rating        :float
#  google_ratings_total :integer
#  google_updated_at    :datetime
#  latitude             :decimal(10, 8)
#  location             :geometry(Point,4
#  longitude            :decimal(11, 8)
#  name                 :string
#  opening_hours        :json
#  phone_number         :string
#  postal_code          :string
#  price_level          :integer
#  state                :string
#  street               :string
#  street_number        :string
#  url                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  google_place_id      :string
#
# Indexes
#
#  index_google_restaurants_on_address          (address)
#  index_google_restaurants_on_city             (city)
#  index_google_restaurants_on_google_place_id  (google_place_id) UNIQUE
#  index_google_restaurants_on_id               (id)
#  index_google_restaurants_on_location         (location) USING gist
#  index_google_restaurants_on_name             (name)
#
require 'rails_helper'

RSpec.describe GoogleRestaurant, type: :model do
  before(:all) do
    ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS postgis')
    # Load spatial reference system data
    ActiveRecord::Base.connection.execute(
      "SELECT postgis_full_version();" # This ensures PostGIS is fully loaded
    )
    ActiveRecord::Base.connection.execute(
      "INSERT INTO spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) VALUES (4326, 'EPSG', 4326, '+proj=longlat +datum=WGS84 +no_defs', 'GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.01745329251994328,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4326\"]]') ON CONFLICT DO NOTHING;"
    )
  end

  describe 'associations' do
    it { should have_many(:restaurants) }
    it { should have_many(:organizations).through(:restaurants) }
  end

  describe 'validations' do
    subject { create(:google_restaurant, :with_location) }

    it { should validate_presence_of(:google_place_id) }
    it { should validate_uniqueness_of(:google_place_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_numericality_of(:latitude) }
    it { should validate_numericality_of(:longitude) }
    it { should validate_numericality_of(:google_rating).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5).allow_nil }
    it { should validate_numericality_of(:google_ratings_total).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:price_level).only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(4).allow_nil }
    it { should validate_inclusion_of(:business_status).in_array(['OPERATIONAL', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY']).allow_nil }
  end

  describe 'scopes' do
    describe '.nearby' do
      let!(:restaurant) { create(:google_restaurant, :with_location) }
      let(:lat) { 37.7749 }
      let(:lon) { -122.4194 }

      it 'returns restaurants within specified distance' do
        nearby = GoogleRestaurant.nearby(lat, lon, 100_000).to_a
        expect(nearby).to include(restaurant)
      end

      it 'does not return restaurants outside specified distance' do
        far_away = create(:google_restaurant, :with_location, latitude: 40.7128, longitude: -74.0060) # NYC coordinates
        nearby = GoogleRestaurant.nearby(lat, lon, 1_000).to_a
        expect(nearby).not_to include(far_away)
      end
    end

    describe '.order_by_distance_from' do
      let!(:near) { create(:google_restaurant, :with_location) }
      let!(:far) { create(:google_restaurant, :with_location, latitude: 40.7128, longitude: -74.0060) }
      let(:lat) { 37.7749 }
      let(:lon) { -122.4194 }

      it 'orders restaurants by distance' do
        ordered = GoogleRestaurant.order_by_distance_from(lat, lon).to_a
        expect(ordered.first).to eq(near)
        expect(ordered.last).to eq(far)
      end
    end
  end

  describe '#coordinates' do
    let(:restaurant) { build(:google_restaurant) }

    it 'returns array of latitude and longitude' do
      expect(restaurant.coordinates).to eq([restaurant.latitude, restaurant.longitude])
    end

    it 'returns nil if coordinates are missing' do
      restaurant.latitude = nil
      expect(restaurant.coordinates).to be_nil
    end
  end

  describe '#update_location' do
    context 'when coordinates are present' do
      let(:restaurant) { create(:google_restaurant, :with_location) }

      it 'sets the location to a POINT' do
        point = ActiveRecord::Base.connection.execute(
          "SELECT ST_AsText(location::geometry) as point FROM google_restaurants WHERE id = #{restaurant.id}"
        ).first['point']
        expect(point).to eq("POINT(#{restaurant.longitude} #{restaurant.latitude})")
      end
    end

    context 'when coordinates are missing' do
      let(:restaurant) { build(:google_restaurant, :without_coordinates) }

      it 'sets location to nil' do
        restaurant.valid? # Trigger validations but allow them to fail
        restaurant.send(:update_location)
        expect(restaurant.location).to be_nil
      end
    end
  end

  describe '#needs_update?' do
    it 'returns true when google_updated_at is nil' do
      restaurant = build(:google_restaurant, google_updated_at: nil)
      expect(restaurant.needs_update?).to be true
    end

    it 'returns true when google_updated_at is older than 30 days' do
      restaurant = build(:google_restaurant, :needs_update)
      expect(restaurant.needs_update?).to be true
    end

    it 'returns false when google_updated_at is recent' do
      restaurant = build(:google_restaurant)
      expect(restaurant.needs_update?).to be false
    end
  end

  describe '#google_place_id_not_undefined' do
    let(:restaurant) { build(:google_restaurant) }

    it 'adds an error when google_place_id is "undefined"' do
      restaurant.google_place_id = "undefined"
      restaurant.valid?
      expect(restaurant.errors[:google_place_id]).to include("cannot be undefined")
    end

    it 'does not add an error when google_place_id is valid' do
      restaurant.valid?
      expect(restaurant.errors[:google_place_id]).to be_empty
    end
  end

  describe '#update_location error handling' do
    let(:restaurant) { build(:google_restaurant) }

    it 'handles database errors gracefully' do
      allow(restaurant).to receive(:location=).and_raise(StandardError.new("Test error"))
      allow(Rails.logger).to receive(:error)

      restaurant.send(:update_location)
      
      expect(Rails.logger).to have_received(:error).with("Failed to update location: Test error")
      expect(restaurant.errors[:location]).to include("could not be updated")
    end
  end

  describe '.find_or_create_from_google_data' do
    let(:google_data) do
      {
        google_place_id: 'test_place_id',
        name: 'Test Restaurant',
        address: '123 Test St',
        city: 'Test City',
        latitude: 37.7749,
        longitude: -122.4194,
        google_rating: 4.5,
        google_ratings_total: 100,
        price_level: 2,
        business_status: 'OPERATIONAL'
      }
    end

    it 'creates a new restaurant if none exists' do
      expect {
        GoogleRestaurant.find_or_create_from_google_data(google_data)
      }.to change(GoogleRestaurant, :count).by(1)
    end

    it 'returns existing restaurant if one exists' do
      restaurant = create(:google_restaurant, :with_location, google_place_id: google_data[:google_place_id])
      result = GoogleRestaurant.find_or_create_from_google_data(google_data)
      expect(result).to eq(restaurant)
    end

    it 'updates existing restaurant with new data' do
      restaurant = create(:google_restaurant, :with_location, :needs_update, google_place_id: google_data[:google_place_id])
      result = GoogleRestaurant.find_or_create_from_google_data(google_data)
      expect(result.name).to eq(google_data[:name])
    end

    it 'returns nil if google_place_id is missing' do
      result = GoogleRestaurant.find_or_create_from_google_data({})
      expect(result).to be_nil
    end
  end
end
