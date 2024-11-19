# frozen_string_literal: true

require "rails_helper"

RSpec.describe SortFormComponent, type: :component do
  let(:url) { "/items" }
  let(:fields) { { "name" => "Name", "date" => "Date", "rating" => "Rating" } }
  let(:current_order) { "name" }
  let(:current_direction) { "asc" }
  let(:additional_fields) { {} }
  let(:params) { { search: "test" } }

  subject(:component) do
    described_class.new(
      url: url,
      fields: fields,
      current_order: current_order,
      current_direction: current_direction,
      additional_fields: additional_fields
    )
  end

  before do
    # Update the translation key stub
    allow_any_instance_of(SortFormComponent).to receive(:t)
      .with("common.sort.sort_by")
      .and_return("Sort by")
    allow_any_instance_of(SortFormComponent).to receive(:params)
      .and_return(params)
    allow_any_instance_of(SortFormComponent).to receive(:heroicon)
      .and_return("icon")
  end

  it "renders the sort form with correct attributes" do
    render_inline(component)
    
    expect(page).to have_css("form#sort-form[action='/items'][method='get']")
    expect(page).to have_css("form.w-full.md\\:w-auto")
  end

  it "renders the hidden search field" do
    render_inline(component)
    
    expect(page).to have_field(type: "hidden", name: "search", with: "test")
  end

  it "renders the label with translated text" do
    render_inline(component)
    
    expect(page).to have_css("label[for='sort-select']")
    expect(page).to have_css("span.label-text", text: "Sort by")
  end

  describe "sort select" do
    it "renders select with correct attributes" do
      render_inline(component)
      
      expect(page).to have_css("select#sort-select[name='order_by']")
      expect(page).to have_css("select.select.select-bordered.w-full.md\\:w-64")
      expect(page).to have_css("select[onchange='this.form.submit()']")
    end

    it "renders all field options" do
      render_inline(component)
      
      fields.each do |value, label|
        expect(page).to have_css("option[value='#{value}']", text: label)
      end
    end

    it "marks the current order as selected" do
      render_inline(component)
      
      expect(page).to have_css("option[value='name'][selected]")
    end
  end

  describe "direction buttons" do
    it "renders ascending button" do
      render_inline(component)
      
      expect(page).to have_css(
        "button[type='submit'][name='order_direction'][value='asc']"
      )
    end

    it "renders descending button" do
      render_inline(component)
      
      expect(page).to have_css(
        "button[type='submit'][name='order_direction'][value='desc']"
      )
    end

    context "with ascending direction" do
      let(:current_direction) { "asc" }

      it "marks ascending button as active" do
        render_inline(component)
        
        expect(page).to have_css("button[value='asc'].btn-active")
        expect(page).not_to have_css("button[value='desc'].btn-active")
      end
    end

    context "with descending direction" do
      let(:current_direction) { "desc" }

      it "marks descending button as active" do
        render_inline(component)
        
        expect(page).to have_css("button[value='desc'].btn-active")
        expect(page).not_to have_css("button[value='asc'].btn-active")
      end
    end
  end

  describe "responsive layout" do
    it "has correct responsive classes" do
      render_inline(component)
      
      expect(page).to have_css("form.w-full.md\\:w-auto")
      expect(page).to have_css("select.w-full.md\\:w-64")
    end
  end

  context "with additional fields" do
    let(:additional_fields) { { category: "books", tag: "fiction" } }

    it "renders hidden fields for additional parameters" do
      render_inline(component)
      
      additional_fields.each do |name, value|
        expect(page).to have_field(name, type: "hidden", with: value)
      end
    end
  end
end
