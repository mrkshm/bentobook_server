require 'rails_helper'

RSpec.describe ImageHandlingService, type: :service do
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:contact) { create(:contact, user: user) }

  let(:image) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg')
  end

  let(:invalid_image) do
    fixture_file_upload(Rails.root.join('spec', 'fixtures', 'invalid.txt'), 'text/plain')
  end

  after(:each) do
    # Clean up any processed images
    ActiveStorage::Blob.unattached.find_each(&:purge)
    FileUtils.rm_rf(Dir["#{Rails.root}/tmp/storage/*"])
  end

  describe '.process_images' do
    context 'with avatar attachment' do
      let(:params) { { contact: { avatar: image } } }

      it 'processes and attaches the avatar' do
        result = ImageHandlingService.process_images(contact, params, compress: true)

        expect(result[:success]).to be true
        expect(contact.avatar).to be_attached
      end

      it 'compresses the image according to specifications' do
        ImageHandlingService.process_images(contact, params, compress: true)

        contact.avatar.analyze
        blob = contact.avatar.blob
        analyzed_metadata = blob.metadata

        expect(analyzed_metadata).to include('width', 'height')
        expect(analyzed_metadata['width']).to be <= 1200
        expect(analyzed_metadata['height']).to be <= 1200
        expect(blob.content_type).to eq('image/jpeg')
      end

      it 'replaces existing avatar when new one is uploaded' do
        # Attach initial avatar
        ImageHandlingService.process_images(contact, params, compress: true)
        original_blob_id = contact.avatar.blob.id

        # Attach new avatar
        new_image = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image2.jpg'), 'image/jpeg')
        new_params = { contact: { avatar: new_image } }
        ImageHandlingService.process_images(contact, new_params, compress: true)

        expect(contact.avatar).to be_attached
        expect(contact.avatar.blob.id).not_to eq(original_blob_id)
        # The old blob should be unattached and can be purged
        expect(ActiveStorage::Blob.find_by(id: original_blob_id)).to be_nil
      end
    end

    context 'without avatar' do
      let(:params) { { contact: { name: 'Test' } } }

      it 'returns failure when no avatar is present' do
        result = ImageHandlingService.process_images(contact, params, compress: true)

        expect(result[:success]).to be false
        expect(result[:message]).to eq('No image params')
      end
    end

    context 'with invalid image' do
      let(:params) { { contact: { avatar: invalid_image } } }

      it 'raises an error for invalid image files' do
        expect {
          ImageHandlingService.process_images(contact, params, compress: true)
        }.to raise_error(ActiveStorage::InvariableError)
      end
    end
  end
end