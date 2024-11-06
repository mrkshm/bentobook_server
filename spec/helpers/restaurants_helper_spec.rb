require 'rails_helper'

RSpec.describe RestaurantsHelper, type: :helper do
  describe '#sort_direction' do
    it 'returns "desc" when current sort is ascending' do
      allow(helper).to receive(:params).and_return({ order_by: 'name', order_direction: 'asc' })
      expect(helper.sort_direction('name')).to eq('desc')
    end

    it 'returns "asc" when current sort is descending' do
      allow(helper).to receive(:params).and_return({ order_by: 'name', order_direction: 'desc' })
      expect(helper.sort_direction('name')).to eq('asc')
    end

    it 'returns "asc" when sorting by a different field' do
      allow(helper).to receive(:params).and_return({ order_by: 'rating', order_direction: 'desc' })
      expect(helper.sort_direction('name')).to eq('asc')
    end
  end

  describe '#restaurant_attribute' do
    let(:cuisine_type) { create(:cuisine_type, name: 'Italian') }
    let(:restaurant) { create(:restaurant, cuisine_type: cuisine_type) }

    before do
      restaurant.tag_list.add('pizza', 'pasta')
      restaurant.save
    end

    it 'returns cuisine type name for :cuisine_type attribute' do
      expect(helper.restaurant_attribute(restaurant, :cuisine_type)).to eq('Italian')
    end

    it 'returns tags for :tags attribute' do
      expect(helper.restaurant_attribute(restaurant, :tags)).to match_array(['pizza', 'pasta'])
    end

    it 'returns combined attribute for other attributes' do
      allow(restaurant).to receive(:combined_name).and_return('Combined Name')
      expect(helper.restaurant_attribute(restaurant, :name)).to eq('Combined Name')
    end
  end

  describe '#price_level_options' do
    it 'returns an array of price level options with symbols and values' do
      expected_options = [
        ['$', 1],
        ['$$', 2],
        ['$$$', 3],
        ['$$$$', 4]
      ]
      
      expect(helper.price_level_options).to eq(expected_options)
    end

    it 'returns options in ascending order of price' do
      options = helper.price_level_options
      values = options.map { |option| option[1] }
      expect(values).to eq(values.sort)
    end

    it 'returns correct symbol count for each level' do
      options = helper.price_level_options
      options.each do |symbol, value|
        expect(symbol.count('$')).to eq(value)
      end
    end
  end
end