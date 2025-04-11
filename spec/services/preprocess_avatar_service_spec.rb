# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreprocessAvatarService do
  include ActionDispatch::TestProcess::FixtureFile

  let(:valid_image) do
    fixture_file_upload(
      Rails.root.join('spec/fixtures/test_image.jpg'),
      'image/jpeg',
      true
    )
  end

  let(:large_image) do
    # Mock a file that's too large
    fixture_file_upload(
      Rails.root.join('spec/fixtures/test_image.jpg'),
      'image/jpeg'
    ).tap do |file|
      allow(file).to receive(:size).and_return(11.megabytes)
    end
  end

  let(:processed_file) { Tempfile.new(['test', '.webp']) }
  let(:mock_builder) { double('ImageProcessing::Builder') }

  before do
    # Setup the processing chain
    allow(ImageProcessing::MiniMagick).to receive(:source).and_return(mock_builder)
    allow(mock_builder).to receive(:resize_to_limit).and_return(mock_builder)
    allow(mock_builder).to receive(:convert).and_return(mock_builder)
    allow(mock_builder).to receive(:saver).and_return(mock_builder)
    allow(mock_builder).to receive(:call).and_return(processed_file)
  end

  after do
    processed_file.close
    processed_file.unlink
  end

  describe '.call' do
    context 'with valid image' do
      it 'processes the image successfully' do
        result = described_class.call(valid_image)

        expect(result[:success]).to be true
        expect(result[:variants]).to include(:thumbnail, :medium)
        
        [:thumbnail, :medium].each do |variant|
          expect(result[:variants][variant][:content_type]).to eq(described_class::OUTPUT_CONTENT_TYPE)
          expect(result[:variants][variant][:filename]).to end_with('.webp')
          expect(result[:variants][variant][:io]).to be_a(File)
          expect(File.exist?(result[:variants][variant][:io].path)).to be true
        end
      end

      it 'processes variants with correct sizes and quality' do
        result = described_class.call(valid_image)

        described_class::VARIANTS.each do |variant_name, config|
          variant = result[:variants][variant_name]
          expect(variant[:filename]).to include("_#{config[:suffix]}")

          # Verify processor was called with correct parameters
          expect(mock_builder).to have_received(:resize_to_limit)
            .with(config[:size][0], config[:size][1])
          expect(mock_builder).to have_received(:saver)
            .with(quality: config[:quality])
        end
      end
    end

    context 'with invalid input' do
      it 'handles nil upload' do
        result = described_class.call(nil)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('No file uploaded')
      end

      it 'handles file too large' do
        result = described_class.call(large_image)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('File too large')
      end

      it 'handles invalid content type' do
        invalid_type_image = valid_image
        allow(invalid_type_image).to receive(:content_type).and_return('text/plain')
        
        result = described_class.call(invalid_type_image)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Invalid file type')
      end

      it 'handles image processing errors' do
        allow(mock_builder).to receive(:call)
          .and_raise(StandardError.new("Processing failed"))

        # Expect logging of error
        expect(Rails.logger).to receive(:error).with("Avatar preprocessing error: Processing failed")
        expect(Rails.logger).to receive(:error).with(instance_of(String)) # backtrace

        result = described_class.call(valid_image)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Processing failed')
      end

      it 'validates quality range' do
        allow(mock_builder).to receive(:call)
          .and_raise(StandardError.new("Quality must be between 1 and 100"))

        expect(Rails.logger).to receive(:error).with(/Avatar preprocessing error: Quality must be between/)
        expect(Rails.logger).to receive(:error).with(instance_of(String)) # backtrace

        result = described_class.call(valid_image)
        expect(result[:success]).to be false
        expect(result[:error]).to match(/Quality must be between/)
      end
    end
  end
end
