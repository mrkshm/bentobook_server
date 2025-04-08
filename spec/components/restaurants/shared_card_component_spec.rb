require "rails_helper"

RSpec.describe Restaurants::SharedCardComponent, type: :component do
  let(:user) { create(:user) }
  let(:owner) { create(:user) }
  let(:list) { create(:list, owner: owner) }
  let(:restaurant) { create(:restaurant) }

  before do
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

    it "shows visit count for current user only" do
      create(:visit, restaurant: restaurant, user: user)
      create(:visit, restaurant: restaurant) # other user's visit

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
      create(:restaurant_copy, user: user, restaurant: restaurant)
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
