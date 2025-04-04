require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { should have_many(:memberships) }
    it { should have_many(:users).through(:memberships) }
    it { should have_many(:restaurants) }
    it { should have_many(:images).dependent(:destroy) }
    it { should have_many(:lists).dependent(:destroy) }
    it { should have_many(:shares).through(:lists) }
  end

  describe 'sharing functionality' do
    let(:organization) { create(:organization) }
    let(:creator) { create(:user) }
    let(:recipient) { create(:user) }
    let(:list) { create(:list, organization: organization, creator: creator) }

    describe '#share_list' do
      it 'creates a pending share for the list' do
        share = organization.share_list(list, recipient, creator: creator)
        expect(share).to be_pending
        expect(share.recipient).to eq(recipient)
        expect(share.creator).to eq(creator)
      end

      it 'raises error when sharing list from another organization' do
        other_org = create(:organization)
        other_list = create(:list, organization: other_org, creator: creator)
        expect {
          organization.share_list(other_list, recipient)
        }.to raise_error(ArgumentError, "List doesn't belong to this organization")
      end
    end

    describe '#shared_lists_with' do
      it 'returns lists shared with the user that are accepted' do
        share = organization.share_list(list, recipient, creator: creator)
        organization.accept_share(share)
        expect(organization.shared_lists_with(recipient)).to include(list)
      end

      it 'does not return pending shared lists' do
        organization.share_list(list, recipient, creator: creator)
        expect(organization.shared_lists_with(recipient)).not_to include(list)
      end
    end

    describe '#pending_shared_lists_with' do
      it 'returns lists shared with the user that are pending' do
        organization.share_list(list, recipient, creator: creator)
        expect(organization.pending_shared_lists_with(recipient)).to include(list)
      end

      it 'does not return accepted shared lists' do
        share = organization.share_list(list, recipient, creator: creator)
        organization.accept_share(share)
        expect(organization.pending_shared_lists_with(recipient)).not_to include(list)
      end
    end

    describe '#accept_share' do
      it 'accepts a pending share' do
        share = organization.share_list(list, recipient, creator: creator)
        organization.accept_share(share)
        expect(share.reload).to be_accepted
      end

      it 'raises error when accepting share from another organization' do
        other_org = create(:organization)
        other_list = create(:list, organization: other_org, creator: creator)
        other_share = other_org.share_list(other_list, recipient, creator: creator)

        expect {
          organization.accept_share(other_share)
        }.to raise_error(ArgumentError, "Share doesn't belong to this organization")
      end
    end

    describe '#reject_share' do
      it 'rejects a pending share' do
        share = organization.share_list(list, recipient, creator: creator)
        organization.reject_share(share)
        expect(share.reload).to be_rejected
      end

      it 'raises error when rejecting share from another organization' do
        other_org = create(:organization)
        other_list = create(:list, organization: other_org, creator: creator)
        other_share = other_org.share_list(other_list, recipient, creator: creator)

        expect {
          organization.reject_share(other_share)
        }.to raise_error(ArgumentError, "Share doesn't belong to this organization")
      end
    end
  end
end
