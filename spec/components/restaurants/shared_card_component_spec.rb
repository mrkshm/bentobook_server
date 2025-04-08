require "rails_helper"

RSpec.describe Restaurants::SharedCardComponent, type: :component do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:list) { create(:list, organization: organization) }
  let(:restaurant) { create(:restaurant) }

  before do
    # No need to associate the user with an organization since we're using list.organization
    list.restaurants << restaurant
  end

  def render_component
    render_inline(described_class.new(
      restaurant: restaurant,
      current_user: user,
      list: list
    ))
  end

  context "when rendering" do
    it "shows restaurant details" do
      render_component
      expect(page).to have_content(restaurant.name)
      expect(page).to have_content(restaurant.cuisine_type.name) if restaurant.cuisine_type
    end

    it "shows visit count for current user's organization only" do
      # Create visit with organization
      create(:visit, restaurant: restaurant, organization_id: organization.id)
      # Create another visit for a different organization
      other_org = create(:organization)
      create(:visit, restaurant: restaurant, organization_id: other_org.id)

      render_component
      expect(page).to have_css(".badge", text: "1")
    end
  end

  context "when restaurant is not imported" do
    it "shows import button" do
      render_component
      expect(page).to have_button(I18n.t("components.shared_restaurant_card_component.add_to_my_restaurants"))
      expect(page).not_to have_css("[data-tip='#{I18n.t("components.shared_restaurant_card_component.already_in_your_restaurants")}']")
    end
  end

  context "when restaurant is already imported" do
    before do
      # Create restaurant copy with organization
      create(:restaurant_copy, organization_id: organization.id, restaurant: restaurant)
    end

    it "shows already imported indicator" do
      render_component
      expect(page).not_to have_button(I18n.t("components.shared_restaurant_card_component.add_to_my_restaurants"))
      expect(page).to have_css("[data-tip='#{I18n.t("components.shared_restaurant_card_component.already_in_your_restaurants")}']")
    end
  end

  context "with tags" do
    before do
      restaurant.tag_list.add("favorite", "italian")
      restaurant.save
    end

    it "shows all tags" do
      render_component
      expect(page).to have_content("favorite")
      expect(page).to have_content("italian")
    end
  end
end
