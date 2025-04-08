require "rails_helper"

RSpec.describe Lists::SharedActionsComponent, type: :component do
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers

  let(:owner) { create(:user) }
  let(:current_user) { create(:user) }
  let(:list) { create(:list, owner: owner) }

  before do
    # Add translations
    I18n.backend.store_translations(:en, {
      components: {
        shared_list_actions_component: {
          shared_by: "Shared by %{owner}",
          import_all: "Import All",
          confirm_import_all: "Add all restaurants to your collection?",
          add_restaurant: "Add Restaurant",
          manage_restaurants: "Manage Restaurants"
        }
      }
    })

    # Mock the profile display name
    allow(owner.profile).to receive(:display_name).and_return("user1")
  end

  # Helper to render with application controller context
  def render_component
    render_inline(described_class.new(list: list, current_user: current_user))
  end

  context "when rendering" do
    it "shows owner information" do
      render_component
      expect(page).to have_content("Shared by user1")
    end
  end

  context "when there are restaurants to import" do
    before do
      create(:restaurant, user: owner)
      list.restaurants << Restaurant.last
    end

    it "shows import all button" do
      render_component
      expect(page).to have_button(I18n.t("components.shared_list_actions_component.import_all"))
    end
  end

  context "when all restaurants are already imported" do
    before do
      restaurant = create(:restaurant, user: owner)
      list.restaurants << restaurant
      create(:restaurant_copy, user: current_user, restaurant: restaurant)
    end

    it "does not show import all button" do
      render_component
      expect(page).not_to have_button(I18n.t("components.shared_list_actions_component.import_all"))
    end
  end

  context "when user has edit permissions" do
    before do
      create(:share, creator: owner, recipient: current_user, shareable: list, permission: :edit, status: :accepted)
    end

    it "shows edit actions" do
      render_component
      expect(page).to have_link(I18n.t("components.shared_list_actions_component.add_restaurant"))
      expect(page).to have_link(I18n.t("components.shared_list_actions_component.manage_restaurants"))
    end
  end

  context "when user does not have edit permissions" do
    before do
      create(:share, creator: owner, recipient: current_user, shareable: list, permission: :view, status: :accepted)
    end

    it "does not show edit actions" do
      render_component
      expect(page).not_to have_link(I18n.t("components.shared_list_actions_component.add_restaurant"))
      expect(page).not_to have_link(I18n.t("components.shared_list_actions_component.manage_restaurants"))
    end
  end
end
