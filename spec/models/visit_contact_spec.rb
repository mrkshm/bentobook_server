require 'rails_helper'

RSpec.describe VisitContact, type: :model do
  describe 'associations' do
    it { should belong_to(:visit) }
    it { should belong_to(:contact) }
  end

  describe 'creation' do
    let(:organization) { create(:organization) }
    let(:restaurant) { create(:restaurant, organization: organization) }
    let(:visit) { create(:visit, organization: organization, restaurant: restaurant) }
    let(:contact) { create(:contact, organization: organization) }

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

    it 'cannot be created with a contact from a different organization' do
      other_org = create(:organization)
      other_contact = create(:contact, organization: other_org)
      visit_contact = VisitContact.new(visit: visit, contact: other_contact)
      expect(visit_contact).to be_invalid
    end
  end
end
