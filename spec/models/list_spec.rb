# == Schema Information
#
# Table name: lists
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string           not null
#  position        :integer
#  premium         :boolean          default(FALSE)
#  visibility      :integer          default("personal")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :bigint           not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_lists_on_creator_id       (creator_id)
#  index_lists_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'associations and validations' do
    it { should belong_to(:organization) }
    it { should belong_to(:creator).class_name('User') }
    it { should have_many(:list_restaurants).dependent(:destroy) }
    it { should have_many(:restaurants).through(:list_restaurants) }
    it { should have_many(:shares).dependent(:destroy) }
    it { should have_many(:shared_organizations).through(:shares).source(:target_organization) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:organization) }
    it { should validate_presence_of(:creator) }
  end

  describe 'scopes' do
    let(:organization) { create(:organization) }
    let(:user) { create(:user) }
    let!(:personal_list) { create(:list, :personal, organization: organization, creator: user) }
    let!(:discoverable_list) { create(:list, :discoverable, organization: organization, creator: user) }

    before do
      create(:membership, user: user, organization: organization)
    end

    it 'filters by visibility' do
      expect(List.personal_lists).to include(personal_list)
      expect(List.discoverable_lists).to include(discoverable_list)
    end

    describe '.shared_with_organization' do
      let(:target_org) { create(:organization) }
      let(:shared_list) { create(:list, :personal, organization: organization, creator: user) }
      
      before do
        create(:share, 
               source_organization: organization, 
               target_organization: target_org, 
               shareable: shared_list, 
               creator: user, 
               status: :accepted)
      end

      it 'returns lists shared with the organization' do
        expect(List.shared_with_organization(target_org)).to include(shared_list)
      end
    end
  end

  describe 'permissions' do
    let(:organization) { create(:organization) }
    let(:target_org) { create(:organization) }
    let(:creator) { create(:user) }
    let(:org_member) { create(:user) }
    let(:shared_org_member) { create(:user) }
    let(:non_member) { create(:user) }
    let(:list) { create(:list, organization: organization, creator: creator) }

    before do
      create(:membership, user: creator, organization: organization)
      create(:membership, user: org_member, organization: organization)
      create(:membership, user: shared_org_member, organization: target_org)
      
      # Share the list with target_org
      create(:share, 
             source_organization: organization, 
             target_organization: target_org, 
             shareable: list, 
             creator: creator, 
             status: :accepted)
    end

    describe '#viewable_by?' do
      it 'returns true for creator' do
        expect(list).to be_viewable_by(creator)
      end

      it 'returns true for organization members' do
        expect(list).to be_viewable_by(org_member)
      end

      it 'returns true for members of organizations the list is shared with' do
        expect(list).to be_viewable_by(shared_org_member)
      end

      it 'returns false for users not in the organization or shared organizations' do
        expect(list).not_to be_viewable_by(non_member)
      end

      it 'returns false for nil user' do
        expect(list).not_to be_viewable_by(nil)
      end
    end

    describe '#editable_by?' do
      it 'returns true for creator' do
        expect(list).to be_editable_by(creator)
      end

      it 'returns true for organization members' do
        expect(list).to be_editable_by(org_member)
      end

      it 'returns false for members of shared organizations' do
        expect(list).not_to be_editable_by(shared_org_member)
      end

      it 'returns false for non-members' do
        expect(list).not_to be_editable_by(non_member)
      end

      it 'returns false for nil user' do
        expect(list).not_to be_editable_by(nil)
      end
    end

    describe '#deletable_by?' do
      it 'returns true for creator' do
        expect(list).to be_deletable_by(creator)
      end

      it 'returns true for other organization members' do
        expect(list).to be_deletable_by(org_member)
      end

      it 'returns false for members of shared organizations' do
        expect(list).not_to be_deletable_by(shared_org_member)
      end

      it 'returns false for non-members' do
        expect(list).not_to be_deletable_by(non_member)
      end

      it 'returns false for nil user' do
        expect(list).not_to be_deletable_by(nil)
      end
    end
  end

  describe 'visibility' do
    let(:organization) { create(:organization) }
    let(:creator) { create(:user) }

    before do
      create(:membership, user: creator, organization: organization)
    end

    it 'defaults to personal' do
      list = create(:list, organization: organization, creator: creator)
      expect(list).to be_personal
    end

    it 'can be made discoverable' do
      list = create(:list, :discoverable, organization: organization, creator: creator)
      expect(list).to be_discoverable
    end
  end
end
