require "rails_helper"

RSpec.describe Lists::StatsComponent, type: :component do
  let(:current_user) { double('User') }
  let(:organization) { double('Organization', id: 1, name: "Test Org") }
  let(:list) { double('List',
    id: 1,
    organization: organization,
    name: "Test List",
    created_at: Time.current,
    updated_at: Time.current
  )}
  let(:statistics) { double('ListStatistics',
    list: list,
    total_restaurants: 0,
    visited_count: 0,
    visited_percentage: 0,
    last_visited_at: nil
  )}

  before do
    # Set up a test controller to mimic the Rails app environment
    @controller = Class.new(ActionController::Base) do
      include ActionView::Helpers::TranslationHelper
      include ActionView::Helpers::DateHelper
    end.new

    # Create a real translation lookup context
    I18n.backend.store_translations(:en, {
      lists: {
        stats_component: {
          total_restaurants: "Total restaurants",
          visited_percentage: "Visited",
          last_updated: "Last updated",
          visited_desc: "%{visited} of %{total}"
        }
      }
    })

    # Mock the date formatting
    allow_any_instance_of(described_class).to receive(:l) do |_, date, options|
      "Jan 1, 2023"
    end

    render_inline(described_class.new(statistics: statistics, list: list))
  end

  after do
    # Clean up translations
    I18n.backend.reload!
  end

  it "renders total restaurants" do
    expect(page).to have_content("Total restaurants")
    expect(page).to have_content("0")
  end

  it "renders visited percentage" do
    expect(page).to have_content("Visited")
    expect(page).to have_content("0%")
  end

  it "renders last updated date" do
    expect(page).to have_content("Last updated")
    expect(page).to have_content("Jan 1, 2023")
  end

  context "with restaurants and visits" do
    let(:statistics) { double('ListStatistics',
      list: list,
      total_restaurants: 1,
      visited_count: 1,
      visited_percentage: 100,
      last_visited_at: Time.current
    )}

    before do
      render_inline(described_class.new(statistics: statistics, list: list))
    end

    it "shows correct statistics" do
      expect(page).to have_content("100%")
      expect(page).to have_content("1 of 1")
    end
  end
end
