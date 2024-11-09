require "rails_helper"

RSpec.describe S3ImageComponent, type: :component do
  let(:mock_blob) do
    double("ActiveStorage::Blob").tap do |blob|
      allow(blob).to receive(:signed_id).and_return("blob_123")
      allow(blob).to receive(:filename).and_return("test.jpg")
      allow(blob).to receive(:content_type).and_return("image/jpeg")
      allow(blob).to receive(:to_i).and_return(123)
    end
  end

  let(:model_name) do
    double("ActiveModel::Name").tap do |name|
      allow(name).to receive(:param_key).and_return("active_storage_attachment")
      allow(name).to receive(:name).and_return("ActiveStorage::Attachment")
      allow(name).to receive(:singular_route_key).and_return("rails/active_storage/attachment")
    end
  end

  let(:mock_image) do
    double("ActiveStorage::Attachment").tap do |image|
      allow(image).to receive(:attached?).and_return(true)
      allow(image).to receive(:to_model).and_return(image)
      allow(image).to receive(:blob).and_return(mock_blob)
      allow(image).to receive(:signed_id).and_return("123")
      allow(image).to receive(:filename).and_return("test.jpg")
      allow(image).to receive(:content_type).and_return("image/jpeg")
      allow(image).to receive(:model_name).and_return(model_name)
    end
  end

  let(:mock_variant) do
    double("ActiveStorage::Variant").tap do |variant|
      allow(variant).to receive(:processed).and_return(true)
      allow(variant).to receive(:key).and_return("variant_key")
      allow(variant).to receive(:url).and_return("https://example.com/variant.jpg")
      allow(variant).to receive(:to_model).and_return(variant)
      allow(variant).to receive(:model_name).and_return(model_name)
      allow(variant).to receive(:signed_id).and_return("variant_123")
      allow(variant).to receive(:blob).and_return(mock_blob)
    end
  end

  let(:mock_variant_record) do
    double("ActiveStorage::VariantRecord").tap do |record|
      allow(record).to receive(:image).and_return(mock_variant)
    end
  end

  it "renders nothing when image is not attached" do
    component = described_class.new(image: nil)
    render_inline(component)
    expect(page).to have_no_css("img")
  end

  it "renders original image when size is :original" do
    component = described_class.new(image: mock_image, size: :original)
    render_inline(component)
    expect(page).to have_css("img[loading='lazy']")
  end

  it "applies custom HTML class when provided" do
    component = described_class.new(image: mock_image, size: :original, html_class: "custom-class")
    render_inline(component)
    expect(page).to have_css("img.custom-class")
  end

  it "renders thumbnail variant with correct options" do
    # Mock the VariantRecord.find_by to return nil (no existing variant)
    allow(ActiveStorage::VariantRecord).to receive(:find_by).and_return(nil)
    
    # Allow variant creation with specific options
    expected_options = {
      resize_to_fill: [100, 100],
      format: :webp,
      saver: { quality: 80 }
    }
    
    # Use with_any_args or with(hash_including(expected_options))
    expect(mock_image).to receive(:variant).with(hash_including(expected_options)).and_return(mock_variant)

    component = described_class.new(image: mock_image, size: :thumbnail)
    render_inline(component)
    
    expect(page).to have_css("img[loading='lazy']")
  end

  it "renders small variant with correct options" do
    allow(ActiveStorage::VariantRecord).to receive(:find_by).and_return(nil)
    
    expected_options = {
      resize_to_limit: [300, 200],
      format: :webp,
      saver: { quality: 80 }
    }
    
    expect(mock_image).to receive(:variant).with(hash_including(expected_options)).and_return(mock_variant)

    component = described_class.new(image: mock_image, size: :small)
    render_inline(component)
    
    expect(page).to have_css("img[loading='lazy']")
  end

  it "renders medium variant with correct options" do
    allow(ActiveStorage::VariantRecord).to receive(:find_by).and_return(nil)
    
    expected_options = {
      resize_to_limit: [600, 400],
      format: :webp,
      saver: { quality: 80 }
    }
    
    expect(mock_image).to receive(:variant).with(hash_including(expected_options)).and_return(mock_variant)

    component = described_class.new(image: mock_image, size: :medium)
    render_inline(component)
    
    expect(page).to have_css("img[loading='lazy']")
  end

  it "renders large variant with correct options" do
    allow(ActiveStorage::VariantRecord).to receive(:find_by).and_return(nil)
    
    expected_options = {
      resize_to_limit: [1200, 800],
      format: :webp,
      saver: { quality: 80 }
    }
    
    expect(mock_image).to receive(:variant).with(hash_including(expected_options)).and_return(mock_variant)

    component = described_class.new(image: mock_image, size: :large)
    render_inline(component)
    
    expect(page).to have_css("img[loading='lazy']")
  end

  it "returns empty variant options for invalid size" do
    allow(ActiveStorage::VariantRecord).to receive(:find_by).and_return(nil)
    
    # Expect variant to be called with an empty hash for invalid size
    expect(mock_image).to receive(:variant).with(hash_including({})).and_return(mock_variant)

    component = described_class.new(image: mock_image, size: :invalid_size)
    render_inline(component)
    
    expect(page).to have_css("img[loading='lazy']")
  end
end
