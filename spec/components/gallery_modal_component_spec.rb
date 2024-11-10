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
      allow(image).to receive(:file).and_return(image)
    end
  end

  before do
    # Mock S3ImageComponent to render an img tag
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
    
    # Check close button
    expect(page).to have_css("button[data-action='click->modal#close']")
    expect(page).to have_css("button svg") # Close icon
  end

  it "generates unique modal ID based on index" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css("#gallery-modal-1")
  end

  it "includes transition classes" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
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
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css(".hidden")
    expect(page).to have_css(".opacity-0")
  end

  it "renders navigation buttons when appropriate" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      total_count: 3,
      current_index: 1
    ))

    expect(page).to have_css("[data-action='click->gallery#previous']")
    expect(page).to have_css("[data-action='click->gallery#next']")
  end

  it "doesn't render previous button on first image" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      total_count: 3,
      current_index: 0
    ))

    expect(page).not_to have_css("[data-action='click->gallery#previous']")
    expect(page).to have_css("[data-action='click->gallery#next']")
  end

  it "doesn't render next button on last image" do
    render_inline(GalleryModalComponent.new(
      image: mock_image,
      total_count: 3,
      current_index: 2
    ))

    expect(page).to have_css("[data-action='click->gallery#previous']")
    expect(page).not_to have_css("[data-action='click->gallery#next']")
  end
end
