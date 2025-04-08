require 'rails_helper'

RSpec.describe RestaurantQuery do
  let(:user) { create(:user) }
  let(:organization) { user.organizations.first }
  let!(:google_restaurant1) { create(:google_restaurant, name: "Pizza Place", latitude: 40.7128, longitude: -74.0060) }
  let!(:google_restaurant2) { create(:google_restaurant, name: "Burger Joint", latitude: 34.0522, longitude: -118.2437) }
  let!(:restaurant1) { create(:restaurant, organization: organization, google_restaurant: google_restaurant1, name: "My Pizza Place", created_at: 2.days.ago, latitude: 40.7128, longitude: -74.0060) }
  let!(:restaurant2) { create(:restaurant, organization: organization, google_restaurant: google_restaurant2, name: "My Burger Joint", created_at: 1.day.ago, latitude: 34.0522, longitude: -118.2437) }
  let(:scope) { Restaurant.all }

  describe '#call' do
    it 'returns all restaurants when no search params are given' do
      query = described_class.new(scope, { organization: organization })
      result = query.call
      expect(result).to match_array([ restaurant1, restaurant2 ])
    end

    it 'filters restaurants by name' do
      query = described_class.new(scope, { organization: organization, search: "Pizza" })
      result = query.call
      expect(result).to match_array([ restaurant1 ])
    end

    it 'sorts restaurants by name' do
      query = described_class.new(scope, { organization: organization, order_by: 'name', order_direction: 'asc' })
      result = query.call
      expect(result.map(&:name)).to eq([ "My Burger Joint", "My Pizza Place" ])
    end

    it 'sorts restaurants by created_at' do
      query = described_class.new(scope, { organization: organization, order_by: 'created_at', order_direction: 'desc' })
      result = query.call
      expect(result).to eq([ restaurant2, restaurant1 ])
    end

    it 'sorts restaurants by distance' do
      query = described_class.new(scope, {
        organization: organization,
        order_by: 'distance',
        latitude: 41.8781,
        longitude: -87.6298
      })
      result = query.call

      # Calculate distances for both restaurants using simple Euclidean distance
      # This avoids the need for PostGIS in tests
      chicago_lat = 41.8781
      chicago_lon = -87.6298

      distances = result.map do |restaurant|
        {
          restaurant: restaurant,
          # Simple Pythagorean calculation instead of PostGIS ST_Distance
          distance: Math.sqrt(
            (restaurant.latitude - chicago_lat)**2 +
            (restaurant.longitude - chicago_lon)**2
          )
        }
      end

      # Verify that the distances are in ascending order
      expect(distances.map { |d| d[:distance] })
        .to eq(distances.map { |d| d[:distance] }.sort)
    end

    it 'returns unsorted results when sorting by distance without coordinates' do
      query = described_class.new(scope, { organization: organization, order_by: 'distance' })
      result = query.call
      expect(result).to match_array([ restaurant1, restaurant2 ])
    end
  end
end
