require "rails_helper"

RSpec.describe Lists::HeaderComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers
    allow(Rails.application.routes).to receive(:url_for).and_return("/")
    allow_any_instance_of(ListHeaderComponent).to receive(:edit_list_path) do |_, list|
      "/lists/#{list.id}/edit"
    end
  end

  let(:current_user) { create(:user) }
  let(:organization) { create(:organization, name: "Org Name", logo: "logo.png") }
  let(:list) { create(:list, organization: organization, name: "My List", visibility: "discoverable") }

  before do
    # Mock organization methods
    allow(list).to receive(:shared?).and_return(false)
    allow(list).to receive(:editable_by?).with(current_user).and_return(true)
  end

  context "when viewing a personal list" do
    before do
      render_inline(described_class.new(list: list, current_user: current_user))
    end

    it "renders list name and visibility" do
      expect(page).to have_content("My List")
      expect(page).to have_selector(".badge", text: I18n.t("lists.visibility.discoverable"))
    end

    it "does not render owner avatar" do
      expect(page).not_to have_selector(".avatar")
    end

    it "renders edit button" do
      expect(page).to have_link(href: /\/lists\/#{list.id}\/edit/)
      expect(page).to have_selector("svg") # Heroicon
    end
  end

  context "when viewing a shared list" do
    before do
      allow(list).to receive(:shared?).and_return(true)
    end

    it "renders the owner avatar" do
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).to have_selector(".avatar")
      expect(page).to have_content("Org Name")
    end

    it "does not render edit button for non-editable lists" do
      allow(list).to receive(:editable_by?).with(current_user).and_return(false)
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).not_to have_link(href: /\/lists\/#{list.id}\/edit/)
    end
  end

  describe "visibility badge styling" do
    it "applies neutral style for personal lists" do
      list.visibility = "personal"
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).to have_selector(".badge-neutral")
    end

    it "applies info style for discoverable lists" do
      render_inline(described_class.new(list: list, current_user: current_user))
      expect(page).to have_selector(".badge-info")
    end
  end
end
