# == Schema Information
#
# Table name: visit_contacts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  contact_id :bigint           not null
#  visit_id   :bigint           not null
#
# Indexes
#
#  index_visit_contacts_on_contact_id  (contact_id)
#  index_visit_contacts_on_visit_id    (visit_id)
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (visit_id => visits.id)
#
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
