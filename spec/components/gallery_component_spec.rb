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

  let(:mock_variation) do
    double("ActiveStorage::Variation").tap do |variation|
      allow(variation).to receive(:transform_values).and_return({})
      allow(variation).to receive(:key).and_return("test_variation")
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
      allow(variant).to receive(:variation).and_return(mock_variation)
    end
  end

  let(:mock_image) do
    double("ActiveStorage::Attachment").tap do |image|
      allow(image).to receive(:attached?).and_return(true)
      allow(image).to receive(:blob).and_return(mock_blob)
      allow(image).to receive(:variant).and_return(mock_variant)
      allow(image).to receive(:file).and_return(image)
      allow(image).to receive(:to_model).and_return(image)
      allow(image).to receive(:url).and_return("https://example.com/test.jpg")
      allow(image).to receive(:model_name).and_return(model_name)
      allow(image).to receive(:variation).and_return(mock_variation)
    end
  end

  let(:images) { [mock_image] }

  before do
    # Mock url_for helper
    allow_any_instance_of(ActionView::Base).to receive(:url_for) do |_, attachment|
      "https://example.com/test.jpg"
    end

    # Mock S3ImageComponent
    allow_any_instance_of(S3ImageComponent).to receive(:render_in).and_wrap_original do |method, context|
      context.tag.img(
        src: "https://example.com/test.jpg",
        class: method.receiver.instance_variable_get(:@html_class),
        data: method.receiver.instance_variable_get(:@data)
      )
    end

    # Mock GalleryModalComponent
    allow_any_instance_of(GalleryModalComponent).to receive(:render_in).and_wrap_original do |method, context|
      context.tag.div(
        id: "gallery-modal-#{method.receiver.instance_variable_get(:@current_index)}",
        class: "modal",
        data: { controller: "modal" }
      )
    end
  end

  it "renders a single image in a grid" do
    render_inline(GalleryComponent.new(images: images))
    
    expect(page).to have_css("div.grid")
    expect(page).to have_css("img.cursor-pointer[src='https://example.com/test.jpg']", count: 1)
  end

  it "handles empty images array" do
    render_inline(GalleryComponent.new(images: []))
    expect(page).to have_css("div.grid")
  end

  it "renders with custom column count" do
    render_inline(GalleryComponent.new(images: images, columns: 4))
    expect(page).to have_css(".grid-cols-1")
    expect(page).to have_css(".lg\\:grid-cols-4")
  end

  describe "modal integration" do
    before do
      render_inline(GalleryComponent.new(images: images))
    end

    it "includes clickable images with modal trigger" do
      expect(page).to have_css("img[data-action='click->gallery#openModal']")
      expect(page).to have_css("img[data-gallery-index-param='0']")
    end

    it "renders modal component for each image" do
      expect(page).to have_css("[data-controller='modal']")
      expect(page).to have_css("#gallery-modal-0")
    end

    it "applies correct classes to images" do
      expect(page).to have_css(".aspect-w-3.aspect-h-2")
      expect(page).to have_css("img.cursor-pointer")
      expect(page).to have_css("img.hover\\:shadow-md")
    end
  end

  describe "with multiple images" do
    let(:images) { [mock_image, mock_image, mock_image] }

    it "renders multiple images with corresponding modals" do
      render_inline(GalleryComponent.new(images: images))
      
      expect(page).to have_css("img.cursor-pointer[src='https://example.com/test.jpg']", count: 3)
      expect(page).to have_css("[data-controller='modal']", count: 3)
      
      3.times do |i|
        expect(page).to have_css("#gallery-modal-#{i}")
        expect(page).to have_css("img[data-gallery-index-param='#{i}']")
      end
    end
  end
end
