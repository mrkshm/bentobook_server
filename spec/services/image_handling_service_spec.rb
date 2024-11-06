require 'rails_helper'

RSpec.describe ImageHandlingService, type: :service do
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  before(:all) do
    # Set up Active Storage URL options for all tests
    ActiveStorage::Current.url_options = { host: "localhost:3000" }
  end

  before(:each) do
    # Clear any existing Active Storage data
    ActiveStorage::Blob.all.each(&:purge)
    ActiveStorage::Attachment.all.each(&:purge)
    
    # Ensure test directory exists and is clean
    FileUtils.mkdir_p(Rails.root.join("tmp/storage"))
    FileUtils.rm_rf(Dir[Rails.root.join("tmp/storage/*")])

    # Use Rails' configuration
    Rails.configuration.active_storage.service = :test
    ActiveStorage::Blob.service = ActiveStorage::Blob.services.fetch(:test)
  end

  after(:each) do
    # Clean up any processed images
    ActiveStorage::Blob.unattached.find_each(&:purge)
    ActiveStorage::Attachment.all.each(&:purge)
    FileUtils.rm_rf(Dir[Rails.root.join("tmp/storage/*")])
  end

  after(:all) do
    # Final cleanup
    FileUtils.rm_rf(Rails.root.join("tmp/storage"))
  end

  let(:user) { create(:user) }
  let(:contact) { create(:contact, user: user) }

  let(:image) do
    path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
    raise "Test image not found at #{path}" unless File.exist?(path)
    fixture_file_upload(path, 'image/jpeg')
  end

  let(:invalid_image) do
    path = Rails.root.join('spec', 'fixtures', 'invalid.txt')
    raise "Invalid test file not found at #{path}" unless File.exist?(path)
    fixture_file_upload(path, 'text/plain')
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

      it 'attaches original image without compression when compress is false' do
        original_image_size = image.size
        result = ImageHandlingService.process_images(contact, params, compress: false)

        expect(result[:success]).to be true
        expect(contact.avatar).to be_attached
        expect(contact.avatar.blob.byte_size).to eq(original_image_size)
        # Verify it's the original image by checking it wasn't converted to jpg
        expect(contact.avatar.blob.filename.to_s).to eq('test_image.jpg')
        expect(contact.avatar.content_type).to eq('image/jpeg')
      end

      it 'shows difference between compressed and uncompressed attachments' do
        # Create two separate image fixtures
        uncompressed_image = fixture_file_upload(
          Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 
          'image/jpeg'
        )
        compressed_image = fixture_file_upload(
          Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 
          'image/jpeg'
        )

        # First attach without compression
        ImageHandlingService.process_images(
          contact, 
          { contact: { avatar: uncompressed_image } }, 
          compress: false
        )
        uncompressed_size = contact.avatar.blob.byte_size

        # Then attach with compression
        ImageHandlingService.process_images(
          contact, 
          { contact: { avatar: compressed_image } }, 
          compress: true
        )
        compressed_size = contact.avatar.blob.byte_size

        expect(compressed_size).to be < uncompressed_size
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
