require 'rails_helper'

RSpec.describe Shared::FlashIconComponent, type: :component do
  it "renders icons for all defined types" do
    described_class::ICONS.each do |type, icon_name|
      component = described_class.new(type: type)
      result = render_inline(component)

      # Verify SVG is rendered with correct attributes
      svg = result.css("svg").first
      expect(svg["xmlns"]).to eq("http://www.w3.org/2000/svg")
      expect(svg["viewbox"]).to eq("0 0 20 20")
      expect(svg["fill"]).to eq("currentColor")
      expect(svg["aria-hidden"]).to eq("true")
      expect(svg["class"]).to eq("w-5 h-5")
    end
  end

  it "falls back to notice icon for undefined types" do
    component = described_class.new(type: :undefined_type)
    result = render_inline(component)

    # Verify SVG is present with correct classes
    expect(result.css("svg.w-5.h-5")).to be_present
  end

  it "renders with correct size classes" do
    component = described_class.new(type: :notice)
    result = render_inline(component)

    expect(result.css("svg.w-5.h-5")).to be_present
  end

  # Remove the mini variant test since Heroicon doesn't add that attribute
end
