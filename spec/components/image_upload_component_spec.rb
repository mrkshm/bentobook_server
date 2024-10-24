require 'rails_helper'

RSpec.describe ImageUploadComponent, type: :component do
  let(:form) { double('form') }
  let(:imageable) { double('imageable', id: 1, images: []) }
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

end
