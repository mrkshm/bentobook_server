require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:display_order) }
  end

  describe 'associations' do
    it { should have_many(:cuisine_types).dependent(:nullify) }
  end

  describe 'scopes' do
    describe '.ordered' do
      it 'returns categories ordered by display_order' do
        category1 = create(:category, display_order: 2)
        category2 = create(:category, display_order: 1)
        category3 = create(:category, display_order: 3)
        
        expect(Category.ordered).to eq([category2, category1, category3])
      end
    end
  end

  describe '#translated_name' do
    it 'returns the translated name if available' do
      category = create(:category, name: 'Asian')
      allow(I18n).to receive(:t).with('categories.asian', default: 'Asian').and_return('Asiatisch')
      
      expect(category.translated_name).to eq('Asiatisch')
    end
    
    it 'returns the original name if no translation is available' do
      category = create(:category, name: 'Special Category')
      allow(I18n).to receive(:t).with('categories.special_category', default: 'Special Category').and_return('Special Category')
      
      expect(category.translated_name).to eq('Special Category')
    end
  end

  describe '#ordered_cuisine_types' do
    it 'returns cuisine types ordered by display_order' do
      category = create(:category)
      cuisine_type1 = create(:cuisine_type, category: category, display_order: 2)
      cuisine_type2 = create(:cuisine_type, category: category, display_order: 1)
      cuisine_type3 = create(:cuisine_type, category: category, display_order: 3)
      
      expect(category.ordered_cuisine_types).to eq([cuisine_type2, cuisine_type1, cuisine_type3])
    end
  end
end
