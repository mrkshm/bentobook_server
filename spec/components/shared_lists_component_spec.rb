require "rails_helper"

RSpec.describe SharedListsComponent, type: :component do
  let(:user) { create(:user) }
  let(:creator) { create(:user) }
  let(:list) { create(:list, owner: creator) }

  context "when user has pending shares" do
    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :pending)
      render_inline(described_class.new(user: user))
    end

    it "renders the pending shares section" do
      expect(page).to have_content(I18n.t('shared_lists_component.pending_shares'))
      expect(page).to have_content(list.name)
      expect(page).to have_content(creator.profile.display_name)
    end

    it "shows accept/decline buttons" do
      expect(page).to have_button(I18n.t('shared_lists_component.accept'))
      expect(page).to have_button(I18n.t('shared_lists_component.decline'))
    end

    it "shows pending badge" do
      expect(page).to have_selector('.badge-warning', text: I18n.t('shared_lists_component.pending'))
    end
  end

  context "when user has accepted shares" do
    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :accepted)
      render_inline(described_class.new(user: user))
    end

    it "renders the shared with you section" do
      expect(page).to have_content(I18n.t('shared_lists_component.shared_with_you'))
      expect(page).to have_content(list.name)
      expect(page).to have_content(creator.profile.display_name)
    end

    it "shows view button" do
      expect(page).to have_link(I18n.t('common.view'))
    end

    it "shows permission badge" do
      expect(page).to have_selector('.badge-info')
    end
  end

  context "when user has both pending and accepted shares" do
    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :pending)
      create(:share, creator: creator, recipient: user, shareable: create(:list), status: :accepted)
      render_inline(described_class.new(user: user))
    end

    it "renders both sections" do
      expect(page).to have_content(I18n.t('shared_lists_component.pending_shares'))
      expect(page).to have_content(I18n.t('shared_lists_component.shared_with_you'))
    end
  end

  context "when user has no shares" do
    it "does not render the component" do
      result = render_inline(described_class.new(user: user))
      expect(result.css('.mb-8')).to be_empty
    end
  end

  context "with multiple shares" do
    let(:another_creator) { create(:user) }
    let(:another_list) { create(:list, owner: another_creator) }

    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :pending)
      create(:share, creator: another_creator, recipient: user, shareable: another_list, status: :pending)
      render_inline(described_class.new(user: user))
    end

    it "shows all pending shares" do
      expect(page).to have_content(list.name)
      expect(page).to have_content(another_list.name)
      expect(page).to have_content(creator.profile.display_name)
      expect(page).to have_content(another_creator.profile.display_name)
    end
  end
end
