require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:visit_contacts) }
    it { should have_many(:visits).through(:visit_contacts) }
    it { should have_one_attached(:avatar) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    
    it 'validates uniqueness of name scoped to user_id' do
      user = create(:user)
      create(:contact, name: 'John', user: user)
      duplicate_contact = build(:contact, name: 'John', user: user)
      expect(duplicate_contact).not_to be_valid
    end
  end

  describe '.search' do
    let(:user) { create(:user) }
    
    it 'returns all records when query is blank' do
      contacts = create_list(:contact, 3, user: user)
      expect(Contact.search(nil)).to match_array(contacts)
      expect(Contact.search('')).to match_array(contacts)
    end

    it 'searches by name' do
      contact = create(:contact, name: 'John Doe', user: user)
      create(:contact, name: 'Jane Smith', user: user)
      
      results = Contact.search('John')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by email' do
      contact = create(:contact, email: 'john@example.com', user: user)
      create(:contact, email: 'jane@example.com', user: user)
      
      results = Contact.search('john@')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by city' do
      contact = create(:contact, city: 'New York', user: user)
      create(:contact, city: 'London', user: user)
      
      results = Contact.search('New')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by country' do
      contact = create(:contact, country: 'USA', user: user)
      create(:contact, country: 'UK', user: user)
      
      results = Contact.search('USA')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by notes' do
      contact = create(:contact, notes: 'Met at conference', user: user)
      create(:contact, notes: 'College friend', user: user)
      
      results = Contact.search('conference')
      expect(results).to contain_exactly(contact)
    end

    it 'is case insensitive' do
      contact = create(:contact, name: 'John Doe', user: user)
      
      results = Contact.search('john')
      expect(results).to contain_exactly(contact)
    end
  end

  describe '#visits_count' do
    let(:contact) { create(:contact) }

    it 'returns 0 when contact has no visits' do
      expect(contact.visits_count).to eq(0)
    end

    it 'returns the correct count of visits' do
      visits = create_list(:visit, 3)
      visits.each do |visit|
        create(:visit_contact, contact: contact, visit: visit)
      end
      expect(contact.visits_count).to eq(3)
    end
  end

  describe '#avatar_changed?' do
    let(:contact) { create(:contact) }

    it 'returns true when avatar_attachment_id changed' do
      allow(contact).to receive(:saved_changes).and_return({'avatar_attachment_id' => [nil, 1]})
      expect(contact.send(:avatar_changed?)).to be true
    end

    it 'returns true when avatar attachment changed' do
      allow(contact).to receive(:attachment_changes).and_return({'avatar' => true})
      expect(contact.send(:avatar_changed?)).to be true
    end

    it 'returns false when avatar has not changed' do
      allow(contact).to receive(:saved_changes).and_return({})
      allow(contact).to receive(:attachment_changes).and_return({})
      expect(contact.send(:avatar_changed?)).to be false
    end
  end
end
