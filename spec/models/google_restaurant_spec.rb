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

  describe 'geocoding' do
    it 'reverse geocodes when latitude or longitude change' do
      google_restaurant = build(:google_restaurant, latitude: 40.7128, longitude: -74.0060)
      expect(google_restaurant).to receive(:reverse_geocode)
      google_restaurant.save
    end
  end

  describe 'scopes' do
    describe '.order_by_distance_from' do
      it 'orders restaurants by distance from a given location' do
        near_restaurant = create(:google_restaurant, latitude: 40.7128, longitude: -74.0060)
        far_restaurant = create(:google_restaurant, latitude: 34.0522, longitude: -118.2437)
        location = [40.7128, -74.0060]

        ordered_restaurants = GoogleRestaurant.order_by_distance_from(location)

        expect(ordered_restaurants.first).to eq(near_restaurant)
        expect(ordered_restaurants.last).to eq(far_restaurant)
      end
    end

    describe '.near' do
      it 'returns restaurants within the specified distance' do
        near_restaurant = create(:google_restaurant, latitude: 40.7128, longitude: -74.0060)
        far_restaurant = create(:google_restaurant, latitude: 34.0522, longitude: -118.2437)
        location = [40.7128, -74.0060]

        nearby_restaurants = GoogleRestaurant.near(location, 100, units: :km)

        expect(nearby_restaurants).to include(near_restaurant)
        expect(nearby_restaurants).not_to include(far_restaurant)
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
end
