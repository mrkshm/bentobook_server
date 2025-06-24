# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  about      :text
#  email      :string
#  name       :string
#  username   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { should have_many(:memberships) }
    it { should have_many(:users).through(:memberships) }
    it { should have_many(:restaurants) }
    it { should have_many(:images).dependent(:destroy) }
    it { should have_many(:lists).dependent(:destroy) }
    it { should have_many(:outgoing_shares) }
    it { should have_many(:incoming_shares) }
    it { should have_many(:shared_lists).through(:incoming_shares) }
  end

  describe 'sharing functionality' do
    let(:source_org) { create(:organization) }
    let(:target_org) { create(:organization) }
    let(:creator) { create(:user) }
    let(:list) { create(:list, organization: source_org, creator: creator) }

    before do
      create(:membership, user: creator, organization: source_org)
    end

    describe '#share_list' do
      it 'creates a pending share for the list' do
        share = source_org.share_list(list, target_org, creator: creator)
        expect(share).to be_pending
        expect(share.target_organization).to eq(target_org)
        expect(share.source_organization).to eq(source_org)
        expect(share.creator).to eq(creator)
      end

      it 'raises error when sharing list from another organization' do
        other_org = create(:organization)
        other_list = create(:list, organization: other_org, creator: creator)
        expect {
          source_org.share_list(other_list, target_org)
        }.to raise_error(ArgumentError, "List doesn't belong to this organization")
      end
    end

    describe '#shared_lists_with' do
      it 'returns lists shared with the organization that are accepted' do
        share = source_org.share_list(list, target_org, creator: creator)
        target_org.accept_share(share)
        expect(source_org.shared_lists_with(target_org)).to include(list)
      end

      it 'does not return pending shared lists' do
        source_org.share_list(list, target_org, creator: creator)
        expect(source_org.shared_lists_with(target_org)).not_to include(list)
      end
    end

    describe '#pending_shared_lists_with' do
      it 'returns lists shared with the organization that are pending' do
        source_org.share_list(list, target_org, creator: creator)
        expect(source_org.pending_shared_lists_with(target_org)).to include(list)
      end

      it 'does not return accepted shared lists' do
        share = source_org.share_list(list, target_org, creator: creator)
        target_org.accept_share(share)
        expect(source_org.pending_shared_lists_with(target_org)).not_to include(list)
      end
    end

    describe '#accept_share' do
      it 'accepts a pending share' do
        share = source_org.share_list(list, target_org, creator: creator)
        target_org.accept_share(share)
        expect(share.reload).to be_accepted
      end

      it 'raises error when accepting share for another organization' do
        other_org = create(:organization)
        share = source_org.share_list(list, target_org, creator: creator)

        expect {
          other_org.accept_share(share)
        }.to raise_error(ArgumentError, "Share doesn't belong to this organization")
      end
    end

    describe '#reject_share' do
      it 'rejects a pending share' do
        share = source_org.share_list(list, target_org, creator: creator)
        target_org.reject_share(share)
        expect(share.reload).to be_rejected
      end

      it 'raises error when rejecting share for another organization' do
        other_org = create(:organization)
        share = source_org.share_list(list, target_org, creator: creator)

        expect {
          other_org.reject_share(share)
        }.to raise_error(ArgumentError, "Share doesn't belong to this organization")
      end
    end
  end
end
