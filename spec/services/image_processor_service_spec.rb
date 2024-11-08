require 'rails_helper'

RSpec.describe ImageProcessorService do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let(:valid_image) do
    path = Rails.root.join('spec/fixtures/test_image.jpg')
    # Create a StringIO object to simulate file content
    file_content = StringIO.new(File.read(path))
    
    # Create a test double that behaves like an uploaded file
    double('UploadedFile').tap do |file|
      allow(file).to receive(:content_type).and_return('image/jpeg')
      allow(file).to receive(:original_filename).and_return('test_image.jpg')
      allow(file).to receive(:to_io).and_return(file_content)
      allow(file).to receive(:rewind).and_return(nil)
      allow(file).to receive(:read).and_return(file_content.read)
    end
  end
  let(:invalid_object) { double('InvalidObject') }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
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

      it 'returns success for array with nil values' do
        service = described_class.new(restaurant, [nil, nil])
        result = service.process
        expect(result).to be_success
      end
    end

    context 'with valid images' do
      before do
        # Ensure create! returns true for all image creation attempts
        allow(restaurant.images).to receive(:create!).and_return(true)
      end

      it 'successfully processes a single image' do
        service = described_class.new(restaurant, valid_image)
        result = service.process
        expect(result).to be_success
        expect(result.error).to be_nil
      end

      it 'successfully processes multiple images' do
        service = described_class.new(restaurant, [valid_image, valid_image])
        result = service.process
        expect(result).to be_success
        expect(result.error).to be_nil
      end
    end

    context 'with invalid images' do
      it 'handles objects without content_type' do
        service = described_class.new(restaurant, invalid_object)
        result = service.process
        expect(result).not_to be_success
        expect(result.error).to eq(I18n.t('errors.images.processing_failed'))
      end

      it 'handles errors during image creation' do
        allow(restaurant.images).to receive(:create!).and_raise(StandardError.new("Test error"))
        service = described_class.new(restaurant, valid_image)
        result = service.process
        expect(result).not_to be_success
        expect(result.error).to eq(I18n.t('errors.images.processing_failed'))
      end
    end

    context 'logging' do
      it 'logs the number of images being processed' do
        service = described_class.new(restaurant, [valid_image, valid_image])
        expect(logger).to receive(:info).with("Processing 2 images")
        service.process
      end

      it 'logs content_type check failures' do
        service = described_class.new(restaurant, invalid_object)
        expect(logger).to receive(:error).with(/Image failed content_type check:/)
        service.process
      end

      it 'logs processing errors' do
        # Create service with valid image
        service = described_class.new(restaurant, valid_image)
        
        # Setup error to be raised during create
        allow(restaurant.images).to receive(:create!).and_raise(StandardError.new("Test error"))
        
        # Verify logging and result
        expect(logger).to receive(:error).with("Image processing failed: Test error")
        result = service.process
        expect(result).not_to be_success
        expect(result.error).to eq(I18n.t('errors.images.processing_failed'))
      end
    end
  end

  describe 'Result' do
    it 'indicates success when initialized with success: true' do
      result = described_class::Result.new(success: true)
      expect(result).to be_success
      expect(result.error).to be_nil
    end

    it 'indicates failure and stores error message when initialized with success: false' do
      error_message = "Processing failed"
      result = described_class::Result.new(success: false, error: error_message)
      expect(result).not_to be_success
      expect(result.error).to eq(error_message)
    end
  end
end
