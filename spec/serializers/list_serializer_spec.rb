require 'rails_helper'

RSpec.describe ListSerializer do
  let(:user) { create(:user) }
  let(:list) { create(:list, :with_restaurants, owner: user) }
  let(:share) { create(:share, :accepted, shareable: list) }

  describe '.render_success' do
    subject(:rendered_json) { described_class.render_success(list, include_restaurants: include_restaurants) }
    let(:include_restaurants) { false }

    before do
      share # Create the share
    end

    it 'follows the JSON API format' do
      expect(rendered_json).to include(
        status: 'success',
        data: be_a(Hash),
        meta: include(:timestamp)
      )
    end

    it 'includes the expected attributes' do
      expect(rendered_json[:data][:attributes]).to include(
        'name',
        'description',
        'visibility',
        'premium',
        'position',
        'created_at',
        'updated_at',
        'restaurant_count',
        'shared_with'
      )
    end

    it 'includes the correct basic attributes' do
      expect(rendered_json[:data][:attributes]).to include(
        'name' => list.name,
        'description' => list.description,
        'visibility' => list.visibility,
        'premium' => list.premium,
        'position' => list.position
      )
    end

    it 'includes the correct restaurant count' do
      expect(rendered_json[:data][:attributes]['restaurant_count']).to eq(3)
    end

    it 'does not include restaurants by default' do
      expect(rendered_json[:data][:attributes]).not_to include('restaurants')
    end

    context 'when include_restaurants is true' do
      let(:include_restaurants) { true }

      it 'includes restaurants with correct attributes' do
        restaurants = rendered_json[:data][:attributes]['restaurants']
        expect(restaurants).to be_an(Array)
        expect(restaurants.length).to eq(3)

        restaurant = restaurants.first
        expect(restaurant).to include(
          'id',
          'name',
          'address',
          'postal_code',
          'city',
          'state',
          'country',
          'rating',
          'price_level'
        )
      end
    end

    it 'includes shared_with information' do
      shared_with = rendered_json[:data][:attributes]['shared_with']
      expect(shared_with).to be_an(Array)
      expect(shared_with.first).to include(
        'user_id' => share.recipient_id,
        'permission' => share.permission
      )
    end
  end

  describe '.render_collection' do
    let(:lists) { create_list(:list, 3, owner: user) }
    subject(:rendered_json) { described_class.render_collection(lists) }

    it 'follows the collection format' do
      expect(rendered_json).to include(
        status: 'success',
        data: be_an(Array),
        meta: include(:timestamp)
      )
    end

    it 'includes the correct number of lists' do
      expect(rendered_json[:data].length).to eq(3)
    end

    context 'with pagination' do
      let(:pagy) { Pagy.new(count: 5, page: 1, items: 2) }
      subject(:rendered_json) { described_class.render_collection(lists, pagy: pagy) }

      it 'includes pagination metadata' do
        expect(rendered_json[:meta][:pagination]).to include(
          current_page: 1,
          total_pages: 3,
          total_count: 5
        )
      end
    end
  end
end
