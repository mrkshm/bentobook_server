require "rails_helper"

RSpec.describe ListActionsComponent, type: :component do
  let(:owner) { create(:user) }
  let(:list) { create(:list, owner: owner) }

  context "when user is the owner" do
    before do
      render_inline(described_class.new(list: list, current_user: owner))
    end

    it "shows all actions" do
      expect(page).to have_link(class: "btn-secondary") # Share button
      expect(page).to have_link(class: "btn-primary")   # Edit button
      expect(page).to have_selector("label", text: /export/i) # Export dropdown
      expect(page).to have_link(class: "btn-ghost")     # Back button
    end
  end

  context "when user has view permission" do
    let(:viewer) { create(:user) }
    
    before do
      create(:share, creator: owner, recipient: viewer, shareable: list, permission: :view, status: :accepted)
      render_inline(described_class.new(list: list, current_user: viewer))
    end

    it "shows only export and back actions" do
      expect(page).not_to have_link(class: "btn-secondary") # No Share button
      expect(page).not_to have_link(class: "btn-primary")   # No Edit button
      expect(page).to have_selector("label", text: /export/i) # Export dropdown
      expect(page).to have_link(class: "btn-ghost")         # Back button
    end
  end

  context "when user has edit permission" do
    let(:editor) { create(:user) }
    
    before do
      create(:share, creator: owner, recipient: editor, shareable: list, permission: :edit, status: :accepted)
      render_inline(described_class.new(list: list, current_user: editor))
    end

    it "shows edit, export and back actions" do
      expect(page).not_to have_link(class: "btn-secondary") # No Share button
      expect(page).to have_link(class: "btn-primary")       # Edit button
      expect(page).to have_selector("label", text: /export/i) # Export dropdown
      expect(page).to have_link(class: "btn-ghost")         # Back button
    end
  end
end
