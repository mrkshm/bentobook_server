# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchFormComponent, type: :component do
  let(:url) { "/search" }
  let(:placeholder) { "Search items..." }
  let(:search_value) { "" }
  let(:additional_fields) { {} }

  subject(:component) do
    described_class.new(
      url: url,
      placeholder: placeholder,
      search_value: search_value,
      additional_fields: additional_fields
    )
  end

  before do
    # Mock translation helper
    allow_any_instance_of(SearchFormComponent).to receive(:t).with("search").and_return("Search")
    allow_any_instance_of(SearchFormComponent).to receive(:t).with("reset").and_return("Reset")
  end

  it "renders the search form with correct attributes" do
    render_inline(component)
    
    expect(page).to have_css("form#search-form[action='/search'][method='get']")
    expect(page).to have_css("form.w-full.md\\:w-1\\/2")
  end

  it "renders the search input with correct attributes" do
    render_inline(component)
    
    expect(page).to have_css("input#search-input[type='text'][name='search']")
    expect(page).to have_css("input.input.input-bordered.w-full")
    expect(page).to have_field("search-input", placeholder: "Search items...")
  end

  it "renders the label with translated text" do
    render_inline(component)
    
    expect(page).to have_css("label[for='search-input']")
    expect(page).to have_css("span.label-text", text: "Search:")
  end

  it "renders submit and reset buttons" do
    render_inline(component)
    
    expect(page).to have_button("Search", type: "submit", class: "btn btn-primary")
    expect(page).to have_button("Reset", type: "button", class: "btn btn-ghost")
  end

  context "with search value" do
    let(:search_value) { "test query" }

    it "renders the input with the search value" do
      render_inline(component)
      expect(page).to have_field("search-input", with: "test query")
    end
  end

  context "with additional fields" do
    let(:additional_fields) { { category: "books", sort: "title" } }

    it "renders hidden fields for additional parameters" do
      render_inline(component)
      
      expect(page).to have_field("category", type: "hidden", with: "books")
      expect(page).to have_field("sort", type: "hidden", with: "title")
    end
  end

  context "with reset button" do
    let(:url) { "/custom/search" }

    it "renders reset button with correct onclick handler" do
      render_inline(component)
      
      expect(page).to have_css(
        "button[onclick=\"window.location='/custom/search'\"]",
        text: "Reset"
      )
    end
  end

  describe "responsive layout" do
    it "has correct responsive classes" do
      render_inline(component)
      
      expect(page).to have_css("div.flex.flex-col.md\\:flex-row")
      expect(page).to have_css("form.w-full.md\\:w-1\\/2")
    end
  end
end
