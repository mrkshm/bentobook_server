require "rails_helper"

RSpec.describe ListStatsComponent, type: :component do
  let(:user) { create(:user) }
  let(:list) { create(:list, owner: user) }
  let(:statistics) { ListStatistics.new(list: list, user: user) }
  
  before do
    render_inline(described_class.new(statistics: statistics, list: list))
  end

  it "renders total restaurants" do
    expect(page).to have_content(I18n.t('list_stats_component.total_restaurants'))
    expect(page).to have_content("0")
  end

  it "renders visited percentage" do
    expect(page).to have_content(I18n.t('list_stats_component.visited_percentage'))
    expect(page).to have_content("0%")
  end

  it "renders last updated date" do
    expect(page).to have_content(I18n.t('list_stats_component.last_updated'))
    expect(page).to have_content(I18n.l(list.created_at, format: :short))
  end

  context "with restaurants and visits" do
    let!(:restaurant) { create(:restaurant) }
    
    before do
      list.restaurants << restaurant
      create(:visit, user: user, restaurant: restaurant)
      render_inline(described_class.new(
        statistics: ListStatistics.new(list: list, user: user),
        list: list
      ))
    end

    it "shows correct statistics" do
      expect(page).to have_content("100%")
      expect(page).to have_content("1 of 1")
    end
  end
end
