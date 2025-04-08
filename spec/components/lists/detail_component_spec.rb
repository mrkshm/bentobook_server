require "rails_helper"

RSpec.describe Lists::DetailComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  before do
    # Fix route helpers for nested components
    allow_any_instance_of(ListHeaderComponent).to receive(:edit_list_path) do |_, list|
      "/lists/#{list.id}/edit"
    end
  end

  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }

  it "renders a list card" do
    render_inline(described_class.new(list: list, current_user: user))
    expect(page).to have_selector(".card")
  end

  it "renders list description when present" do
    list.update(description: "Test description")
    render_inline(described_class.new(list: list, current_user: user))
    expect(page).to have_text("Test description")
  end

  it "sets correct permissions for owner" do
    component = described_class.new(list: list, current_user: user)
    expect(component.send(:permissions)).to include(
      can_edit: true,
      can_delete: true
    )
  end

  context "with shared list" do
    let(:other_user) { create(:user) }
    let(:shared_list) { create(:list, owner: other_user) }

    before do
      create(:share, creator: other_user, recipient: user,
             shareable: shared_list, permission: :view, status: :accepted)
    end

    it "sets correct permissions for viewer" do
      component = described_class.new(list: shared_list, current_user: user)
      expect(component.send(:permissions)).to include(
        can_edit: false,
        can_delete: false
      )
    end
  end
end
