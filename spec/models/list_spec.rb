require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:personal_list) { create(:list, :personal, owner: user) }
    let!(:discoverable_list) { create(:list, :discoverable, owner: user) }

    it 'filters by visibility' do
      expect(List.personal).to include(personal_list)
      expect(List.discoverable_lists).to include(discoverable_list)
    end
  end

  describe '#visited_percentage' do
    let(:list) { create(:list, :with_restaurants) }
    let(:restaurant) { list.restaurants.first }
    
    before do
      create(:visit, restaurant: restaurant, user: list.owner)
    end

    it 'calculates correct percentage' do
      expect(list.visited_percentage).to eq(33) # 1 out of 3 restaurants visited
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should belong_to(:owner) }
  end
end
