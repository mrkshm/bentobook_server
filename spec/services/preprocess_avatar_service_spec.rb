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

  describe '.call' do
    context 'with valid image' do
      it 'processes the image successfully' do
        result = described_class.call(valid_image)

        expect(result[:success]).to be true
        expect(result[:variants]).to include(:thumbnail, :medium)
        
        [:thumbnail, :medium].each do |variant|
          expect(result[:variants][variant][:content_type]).to eq('image/webp')
          expect(result[:variants][variant][:filename]).to end_with('.webp')
          expect(result[:variants][variant][:io]).to be_a(File)
          expect(File.exist?(result[:variants][variant][:io].path)).to be true
        end
      end

      after(:each) do
        # Clean up any processed files
        ObjectSpace.each_object(File) do |f|
          next unless f.path.include?('webp')
          f.close
          File.unlink(f.path) if File.exist?(f.path)
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
    end
  end
end
