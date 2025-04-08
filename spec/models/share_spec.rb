require 'rails_helper'

RSpec.describe Share, type: :model do
  describe 'validations' do
    let(:source_org) { create(:organization) }
    let(:target_org) { create(:organization) }
    let(:creator) { create(:user) }
    let(:list) { create(:list, organization: source_org, creator: creator) }

    before do
      create(:membership, user: creator, organization: source_org)
    end

    it { should belong_to(:creator).class_name('User') }
    it { should belong_to(:source_organization).class_name('Organization') }
    it { should belong_to(:target_organization).class_name('Organization') }
    it { should belong_to(:shareable) }

    it 'validates uniqueness of target_organization for the same shareable and source_organization' do
      create(:share, creator: creator, source_organization: source_org, target_organization: target_org, shareable: list)
      duplicate = build(:share, creator: creator, source_organization: source_org, target_organization: target_org, shareable: list)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:target_organization_id]).to include("has already been taken")
    end

    it 'prevents sharing with the same organization' do
      share = build(:share, creator: creator, source_organization: source_org, target_organization: source_org, shareable: list)

      expect(share).not_to be_valid
      expect(share.errors[:target_organization_id]).to include("can't be the same as source organization")
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

  describe 'scopes' do
    let(:source_org) { create(:organization) }
    let(:target_org) { create(:organization) }
    let(:other_org) { create(:organization) }

    before do
      create(:share, source_organization: source_org, target_organization: target_org, status: :accepted)
      create(:share, source_organization: other_org, target_organization: target_org, status: :pending)
      create(:share, source_organization: source_org, target_organization: other_org, status: :rejected)
    end

    it 'finds shares where organization is the target' do
      shares = Share.shared_with(target_org)
      expect(shares.count).to eq(2)
      expect(shares.pluck(:target_organization_id).uniq).to eq([ target_org.id ])
    end

    it 'finds shares where organization is the source' do
      shares = Share.shared_by(source_org)
      expect(shares.count).to eq(2)
      expect(shares.pluck(:source_organization_id).uniq).to eq([ source_org.id ])
    end
  end
end
