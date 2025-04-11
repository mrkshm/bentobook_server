require 'rails_helper'

RSpec.describe CuisineType, type: :model do
  describe 'validations' do
    it "is valid with a unique name" do
      cuisine_type = CuisineType.new(name: "italian")
      expect(cuisine_type).to be_valid
    end

    it "is invalid without a name" do
      cuisine_type = CuisineType.new(name: nil)
      expect(cuisine_type).to be_invalid
      expect(cuisine_type.errors[:name]).to include("can't be blank")
    end

    it "is invalid with a duplicate name" do
      CuisineType.create(name: "italian")
      cuisine_type = CuisineType.new(name: "italian")
      expect(cuisine_type).to be_invalid
      expect(cuisine_type.errors[:name]).to include("has already been taken")
    end
  end

  describe 'associations' do
    it "belongs to category (optional)" do
      association = described_class.reflect_on_association(:category)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:optional]).to be true
    end

    it "has many restaurants" do
      association = described_class.reflect_on_association(:restaurants)
      expect(association.macro).to eq :has_many
    end
  end

  describe '#translated_name' do
    it 'returns the translated name for a valid cuisine type' do
      cuisine_type = create(:cuisine_type, name: 'italian')
      expect(cuisine_type.translated_name).to eq('Italian')
    end

    it 'returns the original name when no translation exists' do
      cuisine_type = build(:cuisine_type, name: 'not_in_seeds')
      expect(cuisine_type.translated_name).to eq('not_in_seeds')
    end
  end

  describe 'scopes' do
    describe '.alphabetical' do
      it 'sorts cuisine types by their translated names' do
        italian = create(:cuisine_type, name: 'italian')
        american = create(:cuisine_type, name: 'american')
        vietnamese = create(:cuisine_type, name: 'vietnamese')

        sorted_cuisines = CuisineType.alphabetical
        expect(sorted_cuisines).to eq([american, italian, vietnamese])
      end

      it 'sorts multiple cuisine types correctly' do
        french = create(:cuisine_type, name: 'french')
        american = create(:cuisine_type, name: 'american')
        italian = create(:cuisine_type, name: 'italian')

        sorted_names = CuisineType.alphabetical.map(&:translated_name)
        expect(sorted_names).to eq(['American', 'French', 'Italian'])
      end
    end
    
    describe '.by_category' do
      it 'returns cuisine types ordered by category display_order and then cuisine type display_order' do
        category1 = create(:category, display_order: 2)
        category2 = create(:category, display_order: 1)
        
        cuisine_type1 = create(:cuisine_type, category: category1, display_order: 2)
        cuisine_type2 = create(:cuisine_type, category: category1, display_order: 1)
        cuisine_type3 = create(:cuisine_type, category: category2, display_order: 1)
        
        expect(CuisineType.by_category).to eq([cuisine_type3, cuisine_type2, cuisine_type1])
      end
    end
    
    describe '.in_category' do
      it 'returns cuisine types in the specified category ordered by display_order' do
        category = create(:category)
        cuisine_type1 = create(:cuisine_type, category: category, display_order: 2)
        cuisine_type2 = create(:cuisine_type, category: category, display_order: 1)
        cuisine_type3 = create(:cuisine_type, category: create(:category), display_order: 1)
        
        expect(CuisineType.in_category(category.id)).to eq([cuisine_type2, cuisine_type1])
        expect(CuisineType.in_category(category.id)).not_to include(cuisine_type3)
      end
    end
  end
  
  describe '.grouped_by_category' do
    it 'returns cuisine types grouped by category' do
      category1 = create(:category)
      category2 = create(:category)
      
      cuisine_type1 = create(:cuisine_type, category: category1)
      cuisine_type2 = create(:cuisine_type, category: category1)
      cuisine_type3 = create(:cuisine_type, category: category2)
      
      grouped = CuisineType.grouped_by_category
      
      expect(grouped.keys).to contain_exactly(category1, category2)
      expect(grouped[category1]).to contain_exactly(cuisine_type1, cuisine_type2)
      expect(grouped[category2]).to contain_exactly(cuisine_type3)
    end
  end
end
