require "rails_helper"

RSpec.describe Restaurants::PriceLevelComponent, type: :component do
  let(:restaurant) { instance_double("Restaurant", id: 1, price_level: 3) }
  let(:current_locale) { "en" }

  before do
    # Instead of stubbing on 'view', we need to stub on the rendered component instance
    allow_any_instance_of(described_class).to receive(:current_locale).and_return(current_locale)
    allow_any_instance_of(described_class).to receive(:hotwire_native_app?).and_return(false)
    allow_any_instance_of(described_class).to receive(:edit_restaurant_price_level_path).with(restaurant_id: restaurant.id, locale: current_locale).and_return("/restaurants/1/price_level/edit")
    # Add this line to stub the frame_id method
    allow_any_instance_of(described_class).to receive(:frame_id).and_return("restaurant_1_price_level")
  end

  subject { render_inline(described_class.new(restaurant: restaurant, readonly: readonly)) }

  context "when readonly is true" do
    let(:readonly) { true }

    it "renders the price level without any links" do
      expect(subject.css("div[data-testid='price-level-component']")).to be_present
      expect(subject.css("a")).to be_empty
      expect(subject.css("span.text-primary-500").count).to eq(3)
      expect(subject.css("span.text-surface-300").count).to eq(1)
    end
  end

  context "when readonly is false" do
    let(:readonly) { false }

    it "renders the price level with an edit link" do
      expect(subject.css("div[data-testid='price-level-component']")).to be_present
      expect(subject.css("a")).to be_present
      expect(subject.css("span.text-primary-500").count).to eq(3)
      expect(subject.css("span.text-surface-300").count).to eq(1)
    end

    it "includes the correct turbo frame" do
      expect(subject.css("turbo-frame")).to be_present
    end
  end

  context "when restaurant has no price level" do
    let(:readonly) { true }
    let(:restaurant) { instance_double("Restaurant", id: 1, price_level: nil) }

    it "renders all price levels as inactive" do
      expect(subject.css("span.text-surface-300").count).to eq(4)
    end
  end
end
