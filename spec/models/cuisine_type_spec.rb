require 'rails_helper'

RSpec.describe CuisineType, type: :model do
  it "is valid with a unique name" do
    cuisine_type = CuisineType.new(name: "Italian")
    expect(cuisine_type).to be_valid
  end

  it "is invalid without a name" do
    cuisine_type = CuisineType.new(name: nil)
    expect(cuisine_type).to be_invalid
    expect(cuisine_type.errors[:name]).to include("can't be blank")
  end

  it "is invalid with a duplicate name" do
    CuisineType.create(name: "Italian")
    cuisine_type = CuisineType.new(name: "Italian")
    expect(cuisine_type).to be_invalid
    expect(cuisine_type.errors[:name]).to include("has already been taken")
  end

  it "has many restaurants" do
    association = described_class.reflect_on_association(:restaurants)
    expect(association.macro).to eq :has_many
  end
end
