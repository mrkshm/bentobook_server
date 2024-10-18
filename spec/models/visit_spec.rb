require 'rails_helper'

RSpec.describe Visit, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:restaurant) }
    it { should have_many(:visit_contacts) }
    it { should have_many(:contacts).through(:visit_contacts) }
    it { should have_many(:images).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:rating).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5).allow_nil }
  end

  describe 'monetization' do
    let(:user) { create(:user) }
    let(:restaurant) { create(:restaurant, user: user) }

    it 'monetizes price_paid' do
      expect(Visit.monetized_attributes).to have_key('price_paid')
    end

    it 'allows nil values for price_paid' do
      visit = Visit.new(user: user, restaurant: restaurant, price_paid: nil, date: Date.today)
      expect(visit).to be_valid
    end

    it 'sets the correct currency for price_paid' do
      visit = Visit.new(user: user, restaurant: restaurant, price_paid_cents: 1000, price_paid_currency: 'USD', date: Date.today)
      expect(visit.price_paid.currency.iso_code).to eq('USD')
    end
  end

  describe 'creation' do
    let(:user) { create(:user) }
    let(:restaurant) { create(:restaurant, user: user) }

    it 'can be created with valid attributes' do
      visit = Visit.new(
        user: user,
        restaurant: restaurant,
        date: Date.today,
        title: "Great visit",
        rating: 4
      )
      expect(visit).to be_valid
    end

    it 'can be created without a rating' do
      visit = Visit.new(
        user: user,
        restaurant: restaurant,
        date: Date.today,
        title: "Great visit"
      )
      expect(visit).to be_valid
    end

    it 'is invalid with a rating less than 1' do
      visit = Visit.new(
        user: user,
        restaurant: restaurant,
        date: Date.today,
        title: "Great visit",
        rating: 0
      )
      expect(visit).to be_invalid
    end

    it 'is invalid with a rating greater than 5' do
      visit = Visit.new(
        user: user,
        restaurant: restaurant,
        date: Date.today,
        title: "Great visit",
        rating: 6
      )
      expect(visit).to be_invalid
    end
  end
end
