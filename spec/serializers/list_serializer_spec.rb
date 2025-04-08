require 'rails_helper'

RSpec.describe ListSerializer do
  let(:user) { create(:user) }
  let(:source_organization) { user.organizations.first }
  let(:target_organization) { create(:organization) }
  let(:target_user) { create(:user) }
  let(:list) { create(:list, :with_restaurants, organization: source_organization, creator: user) }
  let(:share) do 
    create(:share, 
      :accepted, 
      creator: user,
      source_organization: source_organization,
      target_organization: target_organization,
      shareable: list
    )
  end

  before do
    # Create membership to associate target user with target organization
    create(:membership, user: target_user, organization: target_organization)
  end

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
        'organization_id' => target_organization.id,
        'permission' => share.permission
      )
    end
  end

  describe '.render_collection' do
    let(:lists) { create_list(:list, 3, organization: source_organization, creator: user) }
    let(:pagy) { Pagy.new(count: 3, page: 1, items: 10) }
    let(:pagination) do
      {
        current_page: pagy.page,
        total_pages: pagy.pages,
        total_count: pagy.count
      }
    end

    subject(:rendered_json) { described_class.render_collection(lists, pagy: pagination) }

    it 'follows the collection format' do
      expect(rendered_json).to include(
        status: 'success',
        data: be_an(Array),
        meta: include(:timestamp, :pagination)
      )
      expect(rendered_json[:meta][:pagination]).to include(
        current_page: 1,
        total_pages: 1,
        total_count: 3
      )
    end

    it 'includes the correct number of lists' do
      expect(rendered_json[:data].length).to eq(3)
    end
  end
end
