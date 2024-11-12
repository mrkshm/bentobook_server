require 'rails_helper'

RSpec.describe RestaurantCopy, type: :model do
  describe 'validations' do
    subject { 
      create(:restaurant_copy) 
    }
    
    it { should belong_to(:user) }
    it { should belong_to(:restaurant) }
    it { should belong_to(:copied_restaurant).class_name('Restaurant') }
    it { should validate_uniqueness_of(:user_id).scoped_to(:restaurant_id) }
  end

  describe 'copy creation' do
    let(:owner) { create(:user) }
    let(:recipient) { create(:user) }
    let(:restaurant) { create(:restaurant, user: owner) }
    
    it 'tracks copy creation when restaurant is copied' do
      copied_restaurant = restaurant.copy_for_user(recipient)
      restaurant_copy = RestaurantCopy.last
      
      expect(restaurant_copy).to have_attributes(
        user: recipient,
        restaurant: restaurant,
        copied_restaurant: copied_restaurant
      )
    end
    
    it 'returns existing copy for duplicate requests' do
      first_copy = restaurant.copy_for_user(recipient)
      second_copy = restaurant.copy_for_user(recipient)
      
      expect(second_copy).to eq(first_copy)
      expect(RestaurantCopy.count).to eq(1)
    end
  end

  describe 'lineage tracking' do
    let(:owner) { create(:user) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:original_restaurant) { create(:restaurant, user: owner) }
    
    it 'maintains proper lineage chain' do
      # First copy
      copy1 = original_restaurant.copy_for_user(user1)
      expect(copy1.original_restaurant).to eq(original_restaurant)
      
      # Second copy from original
      copy2 = original_restaurant.copy_for_user(user2)
      expect(copy2.original_restaurant).to eq(original_restaurant)
      
      # Verify copies are tracked
      expect(original_restaurant.copies).to include(copy1, copy2)
    end
    
    it 'returns self when copying for the owner' do
      result = original_restaurant.copy_for_user(owner)
      expect(result).to eq(original_restaurant)
      expect(RestaurantCopy.count).to eq(0)
    end
  end

  describe 'user associations' do
    let(:owner) { create(:user) }
    let(:recipient) { create(:user) }
    let(:restaurant) { create(:restaurant, user: owner) }
    
    before do
      @copy = restaurant.copy_for_user(recipient)
    end
    
    it 'associates copy with correct user' do
      expect(@copy.user).to eq(recipient)
    end
    
    it 'maintains original restaurant ownership' do
      expect(restaurant.user).to eq(owner)
    end
    
    it 'creates proper tracking record' do
      tracking = RestaurantCopy.find_by(
        user: recipient,
        restaurant: restaurant,
        copied_restaurant: @copy
      )
      
      expect(tracking).to be_present
    end
  end
end
