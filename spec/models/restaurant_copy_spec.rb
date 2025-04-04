require 'rails_helper'

RSpec.describe RestaurantCopy, type: :model do
  describe 'validations' do
    subject { 
      create(:restaurant_copy) 
    }
    
    it { should belong_to(:organization) }
    it { should belong_to(:restaurant) }
    it { should belong_to(:copied_restaurant).class_name('Restaurant') }
    it { should validate_uniqueness_of(:organization_id).scoped_to(:restaurant_id) }
  end

  describe 'copy creation' do
    let(:organization) { create(:organization) }
    let(:restaurant) { create(:restaurant, organization: organization) }
    let(:target_organization) { create(:organization) }
    
    it 'tracks copy creation when restaurant is copied' do
      copied_restaurant = restaurant.copy_for_organization(target_organization)
      restaurant_copy = RestaurantCopy.last
      
      expect(restaurant_copy).to have_attributes(
        organization: target_organization,
        restaurant: restaurant,
        copied_restaurant: copied_restaurant
      )
    end
    
    it 'returns existing copy for duplicate requests' do
      first_copy = restaurant.copy_for_organization(target_organization)
      second_copy = restaurant.copy_for_organization(target_organization)
      
      expect(second_copy).to eq(first_copy)
      expect(RestaurantCopy.count).to eq(1)
    end
  end

  describe 'lineage tracking' do
    let(:organization) { create(:organization) }
    let(:org1) { create(:organization) }
    let(:org2) { create(:organization) }
    let(:original_restaurant) { create(:restaurant, organization: organization) }
    
    it 'maintains proper lineage chain' do
      # First copy
      copy1 = original_restaurant.copy_for_organization(org1)
      expect(copy1.original_restaurant).to eq(original_restaurant)
      
      # Second copy from original
      copy2 = original_restaurant.copy_for_organization(org2)
      expect(copy2.original_restaurant).to eq(original_restaurant)
      
      # Verify copies are tracked
      expect(original_restaurant.copies).to include(copy1, copy2)
    end
    
    it 'returns self when copying for the owner organization' do
      result = original_restaurant.copy_for_organization(organization)
      expect(result).to eq(original_restaurant)
      expect(RestaurantCopy.count).to eq(0)
    end
  end

  describe 'organization associations' do
    let(:organization) { create(:organization) }
    let(:target_organization) { create(:organization) }
    let(:restaurant) { create(:restaurant, organization: organization) }
    
    before do
      @copy = restaurant.copy_for_organization(target_organization)
    end
    
    it 'associates copy with correct organization' do
      expect(@copy.organization).to eq(target_organization)
    end
    
    it 'maintains original restaurant ownership' do
      expect(restaurant.organization).to eq(organization)
    end
    
    it 'creates proper tracking record' do
      tracking = RestaurantCopy.find_by(
        organization: target_organization,
        restaurant: restaurant,
        copied_restaurant: @copy
      )
      
      expect(tracking).to be_present
    end
  end
end
