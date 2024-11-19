require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'associations and validations' do
    it { should belong_to(:owner) }
    it { should have_many(:list_restaurants).dependent(:destroy) }
    it { should have_many(:restaurants).through(:list_restaurants) }
    it { should have_many(:shares).dependent(:destroy) }
    it { should have_many(:shared_users).through(:shares) }
    it { should validate_presence_of(:name) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:personal_list) { create(:list, :personal, owner: user) }
    let!(:discoverable_list) { create(:list, :discoverable, owner: user) }

    it 'filters by visibility' do
      expect(List.personal).to include(personal_list)
      expect(List.discoverable).to include(discoverable_list)
    end

    describe '.shared_with' do
      let(:recipient) { create(:user) }
      let(:shared_list) { create(:list, :personal, owner: user) }
      
      before do
        create(:share, creator: user, recipient: recipient, shareable: shared_list, status: :accepted)
      end

      it 'returns lists shared with user' do
        expect(List.shared_with(recipient)).to include(shared_list)
      end
    end
  end

  describe 'permissions' do
    let(:owner) { create(:user) }
    let(:viewer) { create(:user) }
    let(:editor) { create(:user) }
    let(:non_shared_user) { create(:user) }
    let(:list) { create(:list, owner: owner) }

    before do
      create(:share, creator: owner, recipient: viewer, shareable: list, 
             permission: :view, status: :accepted)
      create(:share, creator: owner, recipient: editor, shareable: list, 
             permission: :edit, status: :accepted)
    end

    describe '#viewable_by?' do
      it 'returns true for owner' do
        expect(list).to be_viewable_by(owner)
      end

      it 'returns true for users with view access' do
        expect(list).to be_viewable_by(viewer)
      end

      it 'returns true for users with edit access' do
        expect(list).to be_viewable_by(editor)
      end

      it 'returns false for non-shared users' do
        expect(list).not_to be_viewable_by(non_shared_user)
      end
    end

    describe '#editable_by?' do
      it 'returns true for owner' do
        expect(list).to be_editable_by(owner)
      end

      it 'returns false for users with view access' do
        expect(list).not_to be_editable_by(viewer)
      end

      it 'returns true for users with edit access' do
        expect(list).to be_editable_by(editor)
      end

      it 'returns false for non-shared users' do
        expect(list).not_to be_editable_by(non_shared_user)
      end
    end
  end

  describe '#deletable_by?' do
    let(:owner) { create(:user) }
    let(:editor) { create(:user) }
    let(:list) { create(:list, owner: owner) }
    
    before do
      create(:share, creator: owner, recipient: editor, shareable: list, 
             status: :accepted, permission: :edit)
    end

    it 'returns true for owner' do
      expect(list.deletable_by?(owner)).to be true
    end

    it 'returns false for editor' do
      expect(list.deletable_by?(editor)).to be false
    end

    it 'returns false for nil user' do
      expect(list.deletable_by?(nil)).to be false
    end
  end

  describe 'visibility' do
    it 'defaults to personal' do
      list = create(:list)
      expect(list).to be_personal
    end

    it 'can be made discoverable' do
      list = create(:list, :discoverable)
      expect(list).to be_discoverable
    end
  end
end
