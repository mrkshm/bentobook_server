require 'rails_helper'

RSpec.describe Shared::FlashComponent, type: :component do
  it "renders notice messages with correct styling" do
    result = render_inline(described_class.new(type: :notice, message: "Test notice"))

    expect(result.css("div.bg-primary-100")).to be_present
    expect(result.css("div.text-primary-700")).to be_present
    expect(result.css("p.text-sm").text).to eq("Test notice")
  end

  it "renders success messages with correct styling" do
    result = render_inline(described_class.new(type: :success, message: "Test success"))

    expect(result.css("div.bg-success-100")).to be_present
    expect(result.css("div.text-success-700")).to be_present
    expect(result.css("p.text-sm").text).to eq("Test success")
  end

  it "renders warning messages with correct styling" do
    result = render_inline(described_class.new(type: :warning, message: "Test warning"))

    expect(result.css("div.bg-warning-100")).to be_present
    expect(result.css("div.text-warning-700")).to be_present
    expect(result.css("p.text-sm").text).to eq("Test warning")
  end

  it "renders error messages with correct styling" do
    result = render_inline(described_class.new(type: :error, message: "Test error"))

    expect(result.css("div.bg-error-100")).to be_present
    expect(result.css("div.text-error-700")).to be_present
    expect(result.css("p.text-sm").text).to eq("Test error")
  end

  it "falls back to notice styling for unknown types" do
    result = render_inline(described_class.new(type: :unknown, message: "Unknown type"))

    expect(result.css("div.bg-primary-100")).to be_present
    expect(result.css("div.text-primary-700")).to be_present
  end

  it "renders with an icon" do
    result = render_inline(described_class.new(type: :success, message: "With icon"))

    expect(result.css("svg")).to be_present
  end

  it "accepts string type" do
    result = render_inline(described_class.new(type: "success", message: "String type"))

    expect(result.css("div.bg-success-100")).to be_present
  end

  it "has correct semantic structure" do
    result = render_inline(described_class.new(type: :notice, message: "Test"))

    expect(result.css("div[role='alert']")).to be_present
    expect(result.css("div.flex.items-center")).to be_present
    expect(result.css("div.rounded-lg")).to be_present
  end
end
