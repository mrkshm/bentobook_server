require "rails_helper"

RSpec.describe SharedListsComponent, type: :component do
  let(:user) { create(:user) }
  let(:creator) { create(:user) }
  let(:list) { create(:list, owner: creator) }
  
  # Set up the component controller with Devise test helpers
  before(:each) do
    @controller = ApplicationController.new
    @controller.request = ActionDispatch::TestRequest.create
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  context "when user has pending shares" do
    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :pending)
      render_inline(described_class.new(user: user))
    end

    it "renders the pending shares section" do
      expect(page).to have_content(I18n.t('shared_lists_component.pending_shares'))
    end

    it "renders the list using ListCardComponent" do
      expect(page).to have_content(list.name)
      expect(page).to have_selector('.badge', text: I18n.t("lists.visibility.#{list.visibility}"))
    end

    it "shows the creator's avatar" do
      expect(page).to have_selector('.avatar')
      expect(page).to have_selector('[data-tip*="' + creator.profile.display_name + '"]')
    end

    it "shows accept/decline buttons" do
      expect(page).to have_button(class: 'btn-success')
      expect(page).to have_button(class: 'btn-error')
    end
  end

  context "when user has accepted shares" do
    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :accepted)
      render_inline(described_class.new(user: user))
    end

    it "renders the shared with you section" do
      expect(page).to have_content(I18n.t('shared_lists_component.shared_with_you'))
    end

    it "renders the list using ListCardComponent" do
      expect(page).to have_content(list.name)
      expect(page).to have_selector('.badge', text: I18n.t("lists.visibility.#{list.visibility}"))
    end

    it "shows the creator's avatar" do
      expect(page).to have_selector('.avatar')
      expect(page).to have_selector('[data-tip*="' + creator.profile.display_name + '"]')
    end
  end

  context "when user has both pending and accepted shares" do
    let(:another_list) { create(:list, owner: creator) }

    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :pending)
      create(:share, creator: creator, recipient: user, shareable: another_list, status: :accepted)
      render_inline(described_class.new(user: user))
    end

    it "renders both sections" do
      expect(page).to have_content(I18n.t('shared_lists_component.pending_shares'))
      expect(page).to have_content(I18n.t('shared_lists_component.shared_with_you'))
    end

    it "shows lists in correct sections" do
      within("#pending-lists-section") do
        expect(page).to have_content(list.name)
      end

      within("#shared-lists-section") do
        expect(page).to have_content(another_list.name)
      end
    end
  end

  context "when user has no shares" do
    before do
      render_inline(described_class.new(user: user))
    end

    it "does not render any content in the sections" do
      expect(page).to have_selector("#pending-lists-section")
      expect(page).to have_selector("#shared-lists-section")
      expect(page).not_to have_content(I18n.t('shared_lists_component.pending_shares'))
      expect(page).not_to have_content(I18n.t('shared_lists_component.shared_with_you'))
    end
  end

  context "with multiple shares from different creators" do
    let(:another_creator) { create(:user) }
    let(:another_list) { create(:list, owner: another_creator) }

    before do
      create(:share, creator: creator, recipient: user, shareable: list, status: :pending)
      create(:share, creator: another_creator, recipient: user, shareable: another_list, status: :pending)
      render_inline(described_class.new(user: user))
    end

    it "shows all pending shares with correct creator avatars" do
      expect(page).to have_content(list.name)
      expect(page).to have_content(another_list.name)
      expect(page).to have_selector('[data-tip*="' + creator.profile.display_name + '"]')
      expect(page).to have_selector('[data-tip*="' + another_creator.profile.display_name + '"]')
    end
  end
end
