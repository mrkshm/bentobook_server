require 'rails_helper'

RSpec.describe ImageUploadComponent, type: :component do
  let(:form) { double('form', object_name: 'restaurant') }
  let(:imageable) { double('imageable', id: 1, images: [], class: double(name: 'Restaurant')) }
  # Use a real template instead of a mock for improved HTML rendering
  let(:template) { ApplicationController.new.view_context }

  let(:mock_blob) do
    double("ActiveStorage::Blob").tap do |blob|
      allow(blob).to receive(:signed_id).and_return("blob_123")
      allow(blob).to receive(:filename).and_return("test.jpg")
      allow(blob).to receive(:content_type).and_return("image/jpeg")
      allow(blob).to receive(:to_i).and_return(123)
      allow(blob).to receive(:present?).and_return(true)
    end
  end

  let(:mock_image) do
    double("ActiveStorage::Attachment").tap do |image|
      allow(image).to receive(:attached?).and_return(true)
      allow(image).to receive(:to_model).and_return(image)
      allow(image).to receive(:blob).and_return(mock_blob)
      allow(image).to receive(:id).and_return(1)
    end
  end

  let(:expected_blob_url) { '/rails/active_storage/blobs/redirect/blob_123/test.jpg' }

  subject(:component) { described_class.new(form, imageable, template) }

  before do
    allow(form).to receive(:file_field).and_return('<input type="file" name="images[]" multiple="multiple">')

    # Stub the helper methods directly on the template
    allow(template).to receive(:url_for).with(mock_image).and_return(expected_blob_url)

    # Use a plain HTML string for image_tag to make debugging easier
    allow(template).to receive(:image_tag) do |url, options|
      "<img src=\"#{url}\" class=\"#{options[:class]}\">"
    end

    # If we're testing in isolation, we need to stub any other methods the component uses
    allow_any_instance_of(ImageUploadComponent).to receive(:url_for).with(mock_image).and_return(expected_blob_url)
    allow_any_instance_of(ImageUploadComponent).to receive(:image_tag) do |_, url, options|
      "<img src=\"#{url}\" class=\"#{options[:class]}\">"
    end
  end

  it 'renders the file input field with correct attributes' do
    expected_options = {
      multiple: true,
      accept: 'image/*',
      name: "restaurant[images][]",
      data: {
        image_preview_target: "input",
        action: "change->image-preview#handleFiles"
      },
      class: 'hidden'
    }

    expect(form).to receive(:file_field).with(:images, hash_including(expected_options))
    render_inline(component)
  end

  it 'renders the "Choose Files" button' do
    result = render_inline(component)
    expect(result.css('button').text).to include('Choose Files')
  end

  context 'when imageable has images' do
    before do
      allow(imageable).to receive(:images).and_return([ mock_image ])
    end

    it 'renders existing images' do
      # For debugging
      puts "Rendering component..."
      result = render_inline(component)
      puts "HTML output: #{result.to_html}"

      # Make our expectations more forgiving for now to isolate the issue
      expect(result.css('.image-thumbnail')).to be_present

      # Debug the image tag
      img_tags = result.css('img')
      puts "Image tags found: #{img_tags.count}"
      if img_tags.any?
        puts "First image tag: #{img_tags.first}"
        puts "First image src: #{img_tags.first['src']}"
      else
        puts "No image tags found in rendered HTML"
        # Let's check if our component is even being rendered
        puts "Button tags found: #{result.css('button').count}"
        puts "All content: #{result.to_html}"
      end

      expect(img_tags.first).to be_present, "No img tag was rendered"
      expect(img_tags.first['src']).to eq(expected_blob_url)
      expect(result.css('button[data-image-id="1"]')).to be_present
    end
  end
end
