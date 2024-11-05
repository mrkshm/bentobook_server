require 'rails_helper'

RSpec.describe GoogleRestaurant, type: :model do
  describe 'associations' do
    it { should have_many(:restaurants) }
    it { should have_many(:users).through(:restaurants) }
  end

  describe 'validations' do
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

  describe 'PostGIS functionality' do
    let!(:nyc_restaurant) { create(:google_restaurant, latitude: 40.7128, longitude: -74.0060) }
    let!(:la_restaurant) { create(:google_restaurant, latitude: 34.0522, longitude: -118.2437) }
    
    describe '.order_by_distance_from' do
      it 'orders restaurants by distance from a given point' do
        ordered = GoogleRestaurant.order_by_distance_from(40.7128, -74.0060).to_a
        expect(ordered.first.id).to eq(nyc_restaurant.id)
        expect(ordered.last.id).to eq(la_restaurant.id)
      end
    end

    describe '.nearby' do
      it 'returns restaurants within specified distance' do
        nearby = GoogleRestaurant.nearby(40.7128, -74.0060, 100_000).to_a
        expect(nearby).to include(nyc_restaurant)
        expect(nearby).not_to include(la_restaurant)
      end
    end

    describe '#update_location' do
      it 'updates PostGIS location point when coordinates change' do
        restaurant = create(:google_restaurant)
        new_lat = 41.8781
        new_lon = -87.6298
        
        restaurant.update(latitude: new_lat, longitude: new_lon)
        restaurant.reload
        
        point = ActiveRecord::Base.connection.execute(
          "SELECT ST_X(location::geometry) as lon, ST_Y(location::geometry) as lat FROM google_restaurants WHERE id = #{restaurant.id}"
        ).first
        
        expect(point['lon'].to_f).to be_within(0.0001).of(new_lon)
        expect(point['lat'].to_f).to be_within(0.0001).of(new_lat)
      end
    end
  end

  describe 'scopes' do
    let!(:nyc_restaurant) { create(:google_restaurant, latitude: 40.7128, longitude: -74.0060) }
    let!(:la_restaurant) { create(:google_restaurant, latitude: 34.0522, longitude: -118.2437) }

    describe '.order_by_distance_from' do
      it 'orders restaurants by distance from a given point' do
        lat, lon = 40.7128, -74.0060  # NYC coordinates
        ordered = GoogleRestaurant.order_by_distance_from(lat, lon).to_a
        
        expect(ordered.first.id).to eq(nyc_restaurant.id)
        expect(ordered.last.id).to eq(la_restaurant.id)
      end
    end

    describe '.nearby' do
      it 'returns restaurants within specified distance' do
        lat, lon = 40.7128, -74.0060  # NYC coordinates
        nearby = GoogleRestaurant.nearby(lat, lon, 100_000).to_a
        
        expect(nearby).to include(nyc_restaurant)
        expect(nearby).not_to include(la_restaurant)
      end
    end
  end

  describe '#needs_update?' do
    it 'returns true if google_updated_at is nil' do
      restaurant = build(:google_restaurant, google_updated_at: nil)
      expect(restaurant.needs_update?).to be true
    end

    it 'returns true if google_updated_at is older than 30 days' do
      restaurant = build(:google_restaurant, google_updated_at: 31.days.ago)
      expect(restaurant.needs_update?).to be true
    end

    it 'returns false if google_updated_at is within 30 days' do
      restaurant = build(:google_restaurant, google_updated_at: 29.days.ago)
      expect(restaurant.needs_update?).to be false
    end
  end

  describe 'custom validations' do
    it 'adds an error if google_place_id is "undefined"' do
      google_restaurant = GoogleRestaurant.new(google_place_id: 'undefined')
      expect(google_restaurant).not_to be_valid
      expect(google_restaurant.errors[:google_place_id]).to include("cannot be undefined")
    end
  end

  describe '#coordinates' do
    it 'returns an array of latitude and longitude when both are present' do
      restaurant = build(:google_restaurant, latitude: 40.7128, longitude: -74.0060)
      expect(restaurant.coordinates).to eq([40.7128, -74.0060])
    end

    it 'returns nil when latitude is missing' do
      restaurant = build(:google_restaurant, latitude: nil, longitude: -74.0060)
      expect(restaurant.coordinates).to be_nil
    end

    it 'returns nil when longitude is missing' do
      restaurant = build(:google_restaurant, latitude: 40.7128, longitude: nil)
      expect(restaurant.coordinates).to be_nil
    end
  end

  describe '#update_location' do
    context 'when coordinates are present' do
      it 'sets the location to a POINT' do
        restaurant = build(:google_restaurant, latitude: 40.7128, longitude: -74.0060)
        restaurant.send(:update_location)
        
        # Parse the POINT string to extract coordinates
        point_regex = /POINT\(([-\d.]+) ([-\d.]+)\)/
        match = restaurant.location.match(point_regex)
        lon, lat = match[1].to_f, match[2].to_f
        
        expect(lon).to be_within(0.0001).of(-74.0060)
        expect(lat).to be_within(0.0001).of(40.7128)
      end
    end

    context 'when coordinates are missing' do
      it 'sets the location to nil when latitude is nil' do
        restaurant = build(:google_restaurant, latitude: nil, longitude: -74.0060)
        restaurant.send(:update_location)
        
        expect(restaurant.location).to be_nil
      end

      it 'sets the location to nil when longitude is nil' do
        restaurant = build(:google_restaurant, latitude: 40.7128, longitude: nil)
        restaurant.send(:update_location)
        
        expect(restaurant.location).to be_nil
      end

      it 'sets the location to nil when both coordinates are nil' do
        restaurant = build(:google_restaurant, latitude: nil, longitude: nil)
        restaurant.send(:update_location)
        
        expect(restaurant.location).to be_nil
      end
    end

    context 'when there is an error updating the location' do
      it 'logs the error and adds an error to the model' do
        restaurant = build(:google_restaurant)
        allow(restaurant).to receive(:location=).and_raise(StandardError.new("Test error"))

        # Capture log messages
        expect(Rails.logger).to receive(:error).with("Failed to update location: Test error")
        
        # Call private method
        restaurant.send(:update_location)
        
        expect(restaurant.errors[:location]).to include("could not be updated")
      end

      it 'returns false when there is an error' do
        restaurant = build(:google_restaurant)
        allow(restaurant).to receive(:location=).and_raise(StandardError.new("Test error"))
        
        result = restaurant.send(:update_location)
        expect(result).to be false
      end
    end
  end
end
