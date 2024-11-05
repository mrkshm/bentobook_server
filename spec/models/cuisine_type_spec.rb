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

  it "has many restaurants" do
    association = described_class.reflect_on_association(:restaurants)
    expect(association.macro).to eq :has_many
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
end
