require "rails_helper"

RSpec.describe Restaurants::PriceLevelComponent, type: :component do
  # Instead of using instance_double, let's use a more complete mock
  # that supports the methods needed by dom_id
  let(:restaurant) do
    instance_double(
      "Restaurant",
      id: 1,
      price_level: 3,
      to_key: [ 1 ],      # Add this for dom_id
      to_param: "1",    # Add this for dom_id
      model_name: double(param_key: 'restaurant') # Add this for dom_id
    )
  end
  let(:current_locale) { "en" }

  before do
    # Instead of stubbing on 'view', we need to stub on the rendered component instance
    allow_any_instance_of(described_class).to receive(:current_locale).and_return(current_locale)
    allow_any_instance_of(described_class).to receive(:hotwire_native_app?).and_return(false)
    allow_any_instance_of(described_class).to receive(:edit_restaurant_price_level_path).with(restaurant_id: restaurant.id, locale: current_locale).and_return("/restaurants/1/price_level/edit")
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

      # Select the first component to avoid counting duplicates
      first_component = subject.css("div[data-testid='price-level-component']").first
      active_indicators = first_component.css("span.text-primary-500")
      inactive_indicators = first_component.css("span.text-surface-300")

      expect(active_indicators.count).to eq(3)
      expect(inactive_indicators.count).to eq(1)
    end

    it "includes the correct turbo frame" do
      expect(subject.css("turbo-frame")).to be_present
    end
  end

  context "when restaurant has no price level" do
    let(:readonly) { true }
    # Update this instance double too
    let(:restaurant) do
      instance_double(
        "Restaurant",
        id: 1,
        price_level: nil,
        to_key: [ 1 ],
        to_param: "1",
        model_name: double(param_key: 'restaurant')
      )
    end

    it "renders all price levels as inactive" do
      expect(subject.css("span.text-surface-300").count).to eq(4)
    end
  end
end
