require 'rails_helper'

RSpec.describe ApplicationComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:component) { described_class.new }

  it "inherits from ViewComponent::Base" do
    expect(described_class.superclass).to eq(ViewComponent::Base)
  end

  it "includes HeroiconHelper" do
    expect(described_class.included_modules).to include(HeroiconHelper)
  end

  it "can be instantiated" do
    expect(component).to be_a(described_class)
  end

  it "renders without error" do
    expect { render_inline(component) { "Test content" } }.not_to raise_error
  end

  it "renders its content" do
    result = render_inline(component) { "Test content" }
    expect(result.to_html).to include("Test content")
  end

  context "when using HeroiconHelper methods" do
    it "responds to heroicon method" do
      expect(component).to respond_to(:heroicon)
    end

    it "can render a heroicon" do
      allow(component).to receive(:heroicon).and_return("<svg>Mock Icon</svg>")
      result = render_inline(component) { component.heroicon("user") }
      expect(result.to_html).to include("&lt;svg&gt;Mock Icon&lt;/svg&gt;")
    end
  end
end
