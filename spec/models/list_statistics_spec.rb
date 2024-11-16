require 'rails_helper'

RSpec.describe ListStatistics do
  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }
  let(:statistics) { described_class.new(list: list, user: user) }

  describe '#total_restaurants' do
    it 'returns 0 for empty list' do
      expect(statistics.total_restaurants).to eq(0)
    end

    it 'returns correct count of restaurants' do
      create_list(:list_restaurant, 3, list: list)
      expect(statistics.total_restaurants).to eq(3)
    end
  end

  describe '#visited_count' do
    it 'returns 0 when no restaurants visited' do
      create_list(:list_restaurant, 3, list: list)
      expect(statistics.visited_count).to eq(0)
    end

    it 'returns count of visited restaurants' do
      restaurants = create_list(:restaurant, 3)
      restaurants.each { |r| list.restaurants << r }
      
      # Visit 2 out of 3 restaurants
      create(:visit, user: user, restaurant: restaurants[0])
      create(:visit, user: user, restaurant: restaurants[1])
      
      expect(statistics.visited_count).to eq(2)
    end

    it 'counts restaurant only once even with multiple visits' do
      restaurant = create(:restaurant)
      list.restaurants << restaurant
      
      create_list(:visit, 3, user: user, restaurant: restaurant)
      
      expect(statistics.visited_count).to eq(1)
    end

    it 'only counts visits by the specified user' do
      other_user = create(:user)
      restaurant = create(:restaurant)
      list.restaurants << restaurant
      
      create(:visit, user: other_user, restaurant: restaurant)
      
      expect(statistics.visited_count).to eq(0)
    end
  end

  describe '#visited_percentage' do
    it 'returns 0 for empty list' do
      expect(statistics.visited_percentage).to eq(0)
    end

    it 'returns correct percentage for partially visited list' do
      restaurants = create_list(:restaurant, 4)
      restaurants.each { |r| list.restaurants << r }
      
      # Visit 2 out of 4 restaurants
      create(:visit, user: user, restaurant: restaurants[0])
      create(:visit, user: user, restaurant: restaurants[1])
      
      expect(statistics.visited_percentage).to eq(50)
    end

    it 'returns 100 when all restaurants visited' do
      restaurant = create(:restaurant)
      list.restaurants << restaurant
      create(:visit, user: user, restaurant: restaurant)
      
      expect(statistics.visited_percentage).to eq(100)
    end
  end
end
