require 'rails_helper'

RSpec.describe Share, type: :model do
  describe 'validations' do
    let(:organization) { create(:organization) }
    let(:creator) { create(:user) }
    let(:recipient) { create(:user) }
    let(:list) { create(:list, organization: organization, creator: creator) }
    
    before do
      create(:membership, user: creator, organization: organization)
    end
    
    it { should belong_to(:creator).class_name('User') }
    it { should belong_to(:recipient).class_name('User') }
    it { should belong_to(:shareable) }
    
    it 'validates uniqueness of recipient for the same shareable and creator' do
      create(:share, creator: creator, recipient: recipient, shareable: list)
      duplicate = build(:share, creator: creator, recipient: recipient, shareable: list)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:recipient_id]).to include("has already been taken")
    end
    
    it 'prevents sharing with self' do
      share = build(:share, creator: creator, recipient: creator, shareable: list)
      
      expect(share).not_to be_valid
      expect(share.errors[:recipient_id]).to include("can't be the same as creator")
    end
  end
  
  describe 'status transitions' do
    let(:share) { create(:share, :pending) }
    
    it 'starts as pending' do
      expect(share).to be_pending
    end
    
    it 'can be accepted' do
      share.accepted!
      expect(share).to be_accepted
    end
    
    it 'can be rejected' do
      share.rejected!
      expect(share).to be_rejected
    end
    
    it 'cannot transition from accepted to pending' do
      share.accepted!
      expect { share.pending! }.to raise_error(StandardError)
    end
  end
  
  describe 'permission levels' do
    let(:share) { create(:share) }
    
    it 'defaults to view permission' do
      expect(share).to be_view
    end
    
    it 'can be set to edit permission' do
      share.edit!
      expect(share).to be_edit
    end
    
    it 'can switch between view and edit' do
      share.edit!
      expect(share).to be_edit
      
      share.view!
      expect(share).to be_view
    end
  end

  describe 'reshareable flag' do
    it 'defaults to true' do
      share = create(:share)
      expect(share.reshareable).to be true
    end

    it 'can be set to false' do
      share = create(:share, :not_reshareable)
      expect(share.reshareable).to be false
    end
  end
end
