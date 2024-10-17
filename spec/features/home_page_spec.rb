require 'rails_helper'

RSpec.feature "HomePage", type: :feature do
  scenario "User visits the home page" do
    visit root_path

    expect(page).to have_content("Welcome to Your App")
    expect(page).to have_css("h1", text: "Welcome to Your App")
    expect(page).to have_button("Primary Button")
    expect(page).to have_button("Secondary Button")
    expect(page).to have_css(".card")
    expect(page).to have_css(".card-title", text: "Card title")
    expect(page).to have_button("Buy Now")
  end
end
