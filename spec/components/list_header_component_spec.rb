require "rails_helper"

RSpec.describe ListHeaderComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers
    allow(Rails.application.routes).to receive(:url_for).and_return("/")
    allow_any_instance_of(ListHeaderComponent).to receive(:edit_list_path) do |_, list|
      "/lists/#{list.id}/edit"
    end
  end

  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user, name: "My List") }

  context "when viewing own list" do
    before do
      render_inline(described_class.new(list: list, current_user: user))
    end

    it "renders list name and visibility" do
      expect(page).to have_content("My List")
      expect(page).to have_selector(".badge", text: I18n.t("lists.visibility.#{list.visibility}"))
    end

    it "renders sharee avatars section" do
      expect(page).to have_selector(".mt-2") # ShareeAvatarsComponent container
    end

    it "does not render owner avatar" do
      expect(page).not_to have_selector(".avatar")
    end

    it "renders edit button" do
      expect(page).to have_link(href: /\/lists\/#{list.id}\/edit/)
      expect(page).to have_selector("svg") # Heroicon
    end
  end

  context "when viewing shared list" do
    let(:other_user) { create(:user) }
    let(:shared_list) { create(:list, owner: other_user) }
    
    before do
      # Fix profile name setting
      allow(other_user.profile).to receive(:display_name).and_return("List Owner")
    end
    
    context "with view permission" do
      before do
        create(:share, creator: other_user, recipient: user, 
               shareable: shared_list, permission: :view, status: :accepted)
        render_inline(described_class.new(list: shared_list, current_user: user))
      end

      it "renders owner avatar with tooltip" do
        expect(page).to have_selector(".avatar")
        expect(page).to have_selector("[data-tip*='List Owner']")
      end

      it "does not render sharee avatars section" do
        expect(page).not_to have_selector(".mt-2")
      end

      it "does not render edit button" do
        expect(page).not_to have_link(href: /\/lists\/#{shared_list.id}\/edit/)
      end
    end

    context "with edit permission" do
      before do
        create(:share, creator: other_user, recipient: user, 
               shareable: shared_list, permission: :edit, status: :accepted)
        render_inline(described_class.new(list: shared_list, current_user: user))
      end

      it "renders edit button" do
        expect(page).to have_link(href: /\/lists\/#{shared_list.id}\/edit/)
      end
    end
  end

  describe "visibility badge styling" do
    it "applies neutral style for personal lists" do
      list.update(visibility: :personal)
      render_inline(described_class.new(list: list, current_user: user))
      expect(page).to have_selector(".badge-neutral")
    end

    it "applies info style for discoverable lists" do
      list.update(visibility: :discoverable)
      render_inline(described_class.new(list: list, current_user: user))
      expect(page).to have_selector(".badge-info")
    end
  end
end
