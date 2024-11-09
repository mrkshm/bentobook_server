require "rails_helper"

RSpec.describe GalleryComponent, type: :component do
  let(:model_name) do
    double("ActiveModel::Name").tap do |name|
      allow(name).to receive(:param_key).and_return("blob")
      allow(name).to receive(:name).and_return("ActiveStorage::Blob")
    end
  end

  let(:mock_blob) do
    double("ActiveStorage::Blob").tap do |blob|
      allow(blob).to receive(:signed_id).and_return("blob_123")
      allow(blob).to receive(:filename).and_return("test.jpg")
      allow(blob).to receive(:content_type).and_return("image/jpeg")
      allow(blob).to receive(:to_i).and_return(123)
      allow(blob).to receive(:to_model).and_return(blob)
      allow(blob).to receive(:model_name).and_return(model_name)
    end
  end

  let(:mock_variant) do
    double("ActiveStorage::Variant").tap do |variant|
      allow(variant).to receive(:processed).and_return(true)
      allow(variant).to receive(:url).and_return("https://example.com/variant.jpg")
      allow(variant).to receive(:to_model).and_return(variant)
      allow(variant).to receive(:model_name).and_return(model_name)
      allow(variant).to receive(:signed_id).and_return("variant_123")
      allow(variant).to receive(:blob).and_return(mock_blob)
      allow(variant).to receive(:filename).and_return("test_variant.jpg")
    end
  end

  let(:mock_image) do
    double("ActiveStorage::Attachment").tap do |image|
      allow(image).to receive(:attached?).and_return(true)
      allow(image).to receive(:blob).and_return(mock_blob)
      allow(image).to receive(:variant).and_return(mock_variant)
    end
  end

  let(:images) { [mock_image] }

  it "renders a single image in a grid" do
    render_inline(GalleryComponent.new(images: images))
    expect(page).to have_css("div.grid")
    expect(page).to have_css("img", count: 1)
  end

  it "handles empty images array" do
    render_inline(GalleryComponent.new(images: []))
    expect(page).to have_css("div.grid")
  end
end
