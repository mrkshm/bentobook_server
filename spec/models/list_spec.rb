require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:personal_list) { create(:list, :personal, owner: user) }
    let!(:discoverable_list) { create(:list, :discoverable, owner: user) }

    it 'filters by visibility' do
      expect(List.personal).to include(personal_list)
      expect(List.discoverable).to include(discoverable_list)
    end

    describe '.shared_with' do
      let(:recipient) { create(:user) }
      let(:shared_list) { create(:list, :personal, owner: user) }
      
      before do
        create(:share, creator: user, recipient: recipient, shareable: shared_list, status: :accepted)
      end

      it 'returns lists shared with user' do
        expect(List.shared_with(recipient)).to include(shared_list)
      end
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

  describe 'visibility' do
    it 'defaults to personal' do
      list = create(:list)
      expect(list).to be_personal
    end

    it 'can be made discoverable' do
      list = create(:list, :discoverable)
      expect(list).to be_discoverable
    end
  end
end
