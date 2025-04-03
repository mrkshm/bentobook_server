require 'rails_helper'

RSpec.describe ImageProcessorService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:restaurant) { create(:restaurant, organization: organization) }
  
  # Create a proper test file
  let(:valid_image) do
    temp_file = Tempfile.new(['test_image', '.jpg'])
    temp_file.binmode
    temp_file.write('dummy image content')
    temp_file.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: temp_file,
      filename: 'test_image.jpg',
      type: 'image/jpeg'
    )
  end
  
  let(:invalid_object) { "not_an_image" }
  
  # Create a test logger that stores messages
  let(:logger) { instance_double(ActiveSupport::Logger) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
  end

  after do
    # Clean up temp files
    if valid_image.respond_to?(:tempfile)
      valid_image.tempfile.close
      valid_image.tempfile.unlink
    end
  end

  describe '#process' do
    context 'when no images are present' do
      it 'returns success for nil images' do
        service = described_class.new(restaurant, nil)
        result = service.process
        expect(result).to be_success
      end

      it 'returns success for empty array' do
        service = described_class.new(restaurant, [])
        result = service.process
        expect(result).to be_success
      end
    end

    context 'with valid images' do
      before do
        allow(restaurant.images).to receive(:create!).and_return(true)
      end

      it 'successfully processes a single image' do
        service = described_class.new(restaurant, valid_image)
        expect(logger).to receive(:info).with("Processing 1 images")
        result = service.process
        expect(result).to be_success
      end

      it 'successfully processes multiple images' do
        service = described_class.new(restaurant, [valid_image, valid_image])
        expect(logger).to receive(:info).with("Processing 2 images")
        result = service.process
        expect(result).to be_success
      end
    end

    context 'with invalid images' do
      it 'handles invalid images' do
        service = described_class.new(restaurant, invalid_object)
        result = service.process
        expect(result).to be_success
      end

      it 'handles errors during image creation' do
        allow(restaurant.images).to receive(:create!).and_raise(StandardError.new("Test error"))
        service = described_class.new(restaurant, valid_image)
        expect(logger).to receive(:error).with("Image processing failed: Test error")
        result = service.process
        expect(result).not_to be_success
      end
    end

    context 'with mixed valid and invalid images' do
      it 'processes valid images and skips invalid ones' do
        allow(restaurant.images).to receive(:create!).and_return(true)
        service = described_class.new(restaurant, [valid_image, invalid_object, valid_image])
        
        expect(logger).to receive(:info).with("Processing 3 images")
        
        result = service.process
        expect(result).to be_success
      end
    end
  end
end
