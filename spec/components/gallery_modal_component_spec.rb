require "rails_helper"

RSpec.describe GalleryModalComponent, type: :component do
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

  before do
    # Mock url_for helper to return a simple URL
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
  end

  it "renders modal structure" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    # Check basic structure
    expect(page).to have_css("[role='dialog']")
    expect(page).to have_css("[data-controller='modal']")
    expect(page).to have_css("[data-modal-target='overlay']")
    expect(page).to have_css("[data-modal-target='content']")
    
    # Check accessibility attributes
    expect(page).to have_css("[aria-modal='true']")
    expect(page).to have_css("[aria-labelledby]")
    
    # Check image container structure
    expect(page).to have_css(".relative.w-full.flex.items-center.justify-center")
    expect(page).to have_css("[data-gallery-target='loader']")
    expect(page).to have_css("[data-gallery-target='currentImage']")
  end

  it "renders responsive navigation buttons" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    # Check navigation button positioning
    expect(page).to have_css("button.absolute.left-2.sm\\:left-4")
    expect(page).to have_css("button.absolute.right-2.sm\\:right-4")
    expect(page).to have_css("button.top-1\\/2.-translate-y-1\\/2")
  end

  it "renders image with correct responsive classes" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css(".max-h-\\[90vh\\].sm\\:max-h-\\[80vh\\]")
    expect(page).to have_css(".object-contain")
    expect(page).to have_css(".w-full.h-auto")
  end

  it "generates unique modal ID based on index" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css("#gallery-modal-1")
  end

  it "includes transition classes" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css(".transition-opacity")
    expect(page).to have_css(".duration-300")
    expect(page).to have_css(".ease-in-out")
  end

  it "starts with hidden state" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css(".hidden")
    expect(page).to have_css(".opacity-0")
  end

  it "renders navigation buttons when appropriate" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css("[data-action='click->gallery#previous']")
    expect(page).to have_css("[data-action='click->gallery#next']")
  end

  it "doesn't render previous button on first image" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 0
    ))

    expect(page).not_to have_css("[data-action='click->gallery#previous']")
    expect(page).to have_css("[data-action='click->gallery#next']")
  end

  it "doesn't render next button on last image" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 2
    ))

    expect(page).to have_css("[data-action='click->gallery#previous']")
    expect(page).not_to have_css("[data-action='click->gallery#next']")
  end

  it "includes preload links for adjacent images" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css("link[rel='prefetch']", count: 2)
  end

  it "includes only next preload link for first image" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 0
    ))

    expect(page).to have_css("link[rel='prefetch']", count: 1)
  end

  it "includes only previous preload link for last image" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      images: [mock_image, mock_image, mock_image],
      total_count: 3,
      current_index: 2
    ))

    expect(page).to have_css("link[rel='prefetch']", count: 1)
  end
end
