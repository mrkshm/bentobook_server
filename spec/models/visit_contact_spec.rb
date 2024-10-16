require 'rails_helper'

RSpec.describe VisitContact, type: :model do
  describe 'associations' do
    it { should belong_to(:visit) }
    it { should belong_to(:contact) }
  end

  describe 'creation' do
    let(:user) { create(:user) }
    let(:restaurant) { create(:restaurant, user: user) }
    let(:visit) { create(:visit, user: user, restaurant: restaurant) }
    let(:contact) { create(:contact, user: user) }

    it 'can be created with valid attributes' do
      visit_contact = VisitContact.new(visit: visit, contact: contact)
      expect(visit_contact).to be_valid
    end

    it 'cannot be created without a visit' do
      visit_contact = VisitContact.new(contact: contact)
      expect(visit_contact).to be_invalid
    end

    it 'cannot be created without a contact' do
      visit_contact = VisitContact.new(visit: visit)
      expect(visit_contact).to be_invalid
    end
  end
end
