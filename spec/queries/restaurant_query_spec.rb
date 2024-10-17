require 'rails_helper'

RSpec.describe RestaurantQuery do
  let(:user) { create(:user) }
  let!(:google_restaurant1) { create(:google_restaurant, name: "Pizza Place", latitude: 40.7128, longitude: -74.0060) }
  let!(:google_restaurant2) { create(:google_restaurant, name: "Burger Joint", latitude: 34.0522, longitude: -118.2437) }
  let!(:restaurant1) { create(:restaurant, user: user, google_restaurant: google_restaurant1, name: "My Pizza Place", created_at: 2.days.ago) }
  let!(:restaurant2) { create(:restaurant, user: user, google_restaurant: google_restaurant2, name: "My Burger Joint", created_at: 1.day.ago) }
  let(:scope) { Restaurant.all }

  describe '#call' do
    it 'returns all restaurants when no search params are given' do
      query = described_class.new(scope, { user: user })
      result = query.call
      expect(result).to match_array([restaurant1, restaurant2])
    end

    it 'filters restaurants by name' do
      query = described_class.new(scope, { user: user, search: "Pizza" })
      result = query.call
      expect(result).to match_array([restaurant1])
    end

    it 'sorts restaurants by name' do
      query = described_class.new(scope, { user: user, order_by: 'name', order_direction: 'asc' })
      result = query.call
      expect(result.map(&:name)).to eq(["My Burger Joint", "My Pizza Place"])
    end

    it 'sorts restaurants by created_at' do
      query = described_class.new(scope, { user: user, order_by: 'created_at', order_direction: 'desc' })
      result = query.call
      expect(result).to eq([restaurant2, restaurant1])
    end

    it 'sorts restaurants by distance' do
      query = described_class.new(scope, { 
        user: user, 
        order_by: 'distance', 
        latitude: 41.8781, 
        longitude: -87.6298
      })
      result = query.call
      expect(result.first).to eq(restaurant1)
      expect(result.last).to eq(restaurant2)
    end

    it 'returns unsorted results when sorting by distance without coordinates' do
      query = described_class.new(scope, { user: user, order_by: 'distance' })
      result = query.call
      expect(result).to match_array([restaurant1, restaurant2])
    end
  end
end
