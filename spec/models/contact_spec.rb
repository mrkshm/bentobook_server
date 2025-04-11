require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'associations' do
    it { should belong_to(:organization) }
    it { should have_many(:visit_contacts) }
    it { should have_many(:visits).through(:visit_contacts) }
    it { should have_one_attached(:avatar) }  # Temporary for migration
    it { should have_one_attached(:avatar_medium) }
    it { should have_one_attached(:avatar_thumbnail) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    
    it 'validates uniqueness of name scoped to organization_id' do
      organization = create(:organization)
      create(:contact, name: 'John', organization: organization)
      duplicate_contact = build(:contact, name: 'John', organization: organization)
      expect(duplicate_contact).not_to be_valid
    end
  end

  describe '.frequently_used_with' do
    let(:organization) { create(:organization) }
    let(:visit) { create(:visit, organization: organization) }
    let!(:contact1) { create(:contact, name: 'Alice', organization: organization) }
    let!(:contact2) { create(:contact, name: 'Bob', organization: organization) }
    let!(:contact3) { create(:contact, name: 'Charlie', organization: organization) }
    let!(:contact4) { create(:contact, name: 'David', organization: organization) }
    let!(:contact5) { create(:contact, name: 'Eve', organization: organization) }
    let!(:contact6) { create(:contact, name: 'Frank', organization: organization) }

    before do
      # Create some visit history
      other_visits = create_list(:visit, 3, organization: organization)
      
      # contact1 has 3 visits
      other_visits.each do |v|
        create(:visit_contact, contact: contact1, visit: v)
      end

      # contact2 has 2 visits
      create(:visit_contact, contact: contact2, visit: other_visits[0])
      create(:visit_contact, contact: contact2, visit: other_visits[1])

      # contact3 has 1 visit
      create(:visit_contact, contact: contact3, visit: other_visits[0])

      # contact4, contact5, contact6 have no visits
    end

    context 'when total available contacts is less than or equal to limit' do
      before do
        # Add some contacts to the current visit
        create(:visit_contact, contact: contact5, visit: visit)
        create(:visit_contact, contact: contact6, visit: visit)
      end

      it 'returns all available contacts ordered by name' do
        result = Contact.frequently_used_with(organization, visit)
        expect(result).to eq([contact1, contact2, contact3, contact4])
      end
    end

    context 'when total available contacts is more than limit' do
      it 'returns contacts ordered by visit count and name' do
        result = Contact.frequently_used_with(organization, visit, limit: 3)
        expect(result).to eq([contact1, contact2, contact3])
      end
    end

    context 'when contacts belong to different organization' do
      let(:other_org) { create(:organization) }
      let!(:other_contact) { create(:contact, organization: other_org) }

      it 'does not include contacts from other organizations' do
        result = Contact.frequently_used_with(organization, visit)
        expect(result).not_to include(other_contact)
      end
    end
  end

  describe '.search' do
    let(:organization) { create(:organization) }
    
    it 'returns all records when query is blank' do
      contacts = create_list(:contact, 3, organization: organization)
      expect(Contact.search(nil)).to match_array(contacts)
      expect(Contact.search('')).to match_array(contacts)
    end

    it 'searches by name' do
      contact = create(:contact, name: 'John Doe', organization: organization)
      create(:contact, name: 'Jane Smith', organization: organization)
      
      results = Contact.search('John')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by email' do
      contact = create(:contact, email: 'john@example.com', organization: organization)
      create(:contact, email: 'jane@example.com', organization: organization)
      
      results = Contact.search('john@')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by city' do
      contact = create(:contact, city: 'New York', organization: organization)
      create(:contact, city: 'London', organization: organization)
      
      results = Contact.search('New')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by country' do
      contact = create(:contact, country: 'USA', organization: organization)
      create(:contact, country: 'UK', organization: organization)
      
      results = Contact.search('USA')
      expect(results).to contain_exactly(contact)
    end

    it 'searches by notes' do
      contact = create(:contact, notes: 'Met at conference', organization: organization)
      create(:contact, notes: 'College friend', organization: organization)
      
      results = Contact.search('conference')
      expect(results).to contain_exactly(contact)
    end

    it 'is case insensitive' do
      contact = create(:contact, name: 'John Doe', organization: organization)
      
      results = Contact.search('john')
      expect(results).to contain_exactly(contact)
    end
  end

  describe '#visits_count' do
    let(:organization) { create(:organization) }
    let(:contact) { create(:contact, organization: organization) }

    it 'returns 0 when contact has no visits' do
      expect(contact.visits_count).to eq(0)
    end

    it 'returns the correct count of visits' do
      visits = create_list(:visit, 3, organization: organization)
      visits.each do |visit|
        create(:visit_contact, contact: contact, visit: visit)
      end
      expect(contact.visits_count).to eq(3)
    end
  end

  describe '#avatar_changed?' do
    let(:contact) { create(:contact) }

    it 'returns true when avatar_medium_attachment_id changed' do
      allow(contact).to receive(:saved_changes).and_return({'avatar_medium_attachment_id' => [nil, 1]})
      expect(contact.send(:avatar_changed?)).to be true
    end

    it 'returns true when avatar_thumbnail_attachment_id changed' do
      allow(contact).to receive(:saved_changes).and_return({'avatar_thumbnail_attachment_id' => [nil, 1]})
      expect(contact.send(:avatar_changed?)).to be true
    end

    it 'returns true when avatar_medium attachment changed' do
      allow(contact).to receive(:attachment_changes).and_return({'avatar_medium' => true})
      expect(contact.send(:avatar_changed?)).to be true
    end

    it 'returns true when avatar_thumbnail attachment changed' do
      allow(contact).to receive(:attachment_changes).and_return({'avatar_thumbnail' => true})
      expect(contact.send(:avatar_changed?)).to be true
    end

    it 'returns false when avatars have not changed' do
      allow(contact).to receive(:saved_changes).and_return({})
      allow(contact).to receive(:attachment_changes).and_return({})
      expect(contact.send(:avatar_changed?)).to be false
    end
  end

  describe '#avatar_medium_url' do
    let(:contact) { create(:contact) }
    let(:host) { 'http://example.com' }

    before do
      allow(Rails.application.config.action_mailer).to receive(:default_url_options).and_return({ host: host })
    end

    it 'returns nil when no avatar_medium is attached' do
      expect(contact.avatar_medium_url).to be_nil
    end

    it 'returns the url when avatar_medium is attached' do
      contact.avatar_medium.attach(io: File.open(Rails.root.join('spec/fixtures/avatar.jpg')), filename: 'avatar.jpg')
      expect(contact.avatar_medium_url).to start_with(host)
    end
  end

  describe '#avatar_thumbnail_url' do
    let(:contact) { create(:contact) }
    let(:host) { 'http://example.com' }

    before do
      allow(Rails.application.config.action_mailer).to receive(:default_url_options).and_return({ host: host })
    end

    it 'returns nil when no avatar_thumbnail is attached' do
      expect(contact.avatar_thumbnail_url).to be_nil
    end

    it 'returns the url when avatar_thumbnail is attached' do
      contact.avatar_thumbnail.attach(io: File.open(Rails.root.join('spec/fixtures/avatar.jpg')), filename: 'avatar.jpg')
      expect(contact.avatar_thumbnail_url).to start_with(host)
    end
  end
end
