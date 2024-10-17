require 'rails_helper'

RSpec.describe ImageUploadComponent, type: :component do
  let(:form) { double('form') }
  let(:imageable) { double('imageable', images: []) }
  let(:template) { double('template') }

  subject(:component) { described_class.new(form, imageable, template) }

  before do
    allow(form).to receive(:file_field).and_return('<input type="file" name="images[]" multiple="multiple" data-direct-upload="true">')
    allow(form).to receive(:check_box).and_return('<input type="checkbox">')
    allow(form).to receive(:label).and_return('<label></label>')
    allow(template).to receive(:image_path).and_return('/images/1')
    allow(template).to receive(:link_to).and_return('<a href="#">Delete</a>')
  end

  it 'renders the file input field' do
    expect(form).to receive(:file_field).with(:images, hash_including(multiple: true, direct_upload: true))
    render_inline(component)
  end

  it 'renders the "Choose Files" button' do
    result = render_inline(component)
    expect(result.css('button').text).to include('Choose Files')
  end

  it 'renders the reset button' do
    result = render_inline(component)
    expect(result.css('button').text).to include('Reset')
  end

  context 'when there are no images' do
    it 'displays the "No files selected" message' do
      result = render_inline(component)
      expect(result.text).to include('No files selected')
    end
  end

  context 'when there are existing images' do
    let(:model_name) { double('model_name', param_key: 'image', name: 'Image', singular_route_key: 'image') }
    let(:model) { double('model', model_name: model_name, persisted?: true) }
    let(:processed_variant) { double('processed_variant', to_model: model) }
    let(:variant) { double('variant', processed: processed_variant, to_model: model) }
    let(:blob) { double('blob') }
    let(:image_file) { double('file', attached?: true, variable?: true, blob: blob) }
    let(:image1) { double('image', id: 1, file: image_file, persisted?: true, is_cover?: false) }
    let(:image2) { double('image', id: 2, file: double('file', attached?: true, variable?: false), persisted?: true, is_cover?: true) }
    let(:imageable) { double('imageable', images: [image1, image2]) }

    before do
      allow(image_file).to receive(:variant).and_return(variant)
      allow(blob).to receive(:variant).and_return(variant)
      allow(variant).to receive(:resize_to_limit).with([100, 100]).and_return(processed_variant)
      allow(template).to receive(:image_tag).and_return('<img src="image1.jpg">')
      allow(template).to receive(:image_tag).with(processed_variant, hash_including(class: "rounded-lg shadow-md w-full h-full object-cover")).and_return('<img src="image1.jpg" class="rounded-lg shadow-md w-full h-full object-cover">')
    end

    it 'renders existing images' do
      result = render_inline(component)
      expect(result.css('.image-thumbnail').count).to eq(2)
    end
  end
end
