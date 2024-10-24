require 'rails_helper'

RSpec.describe ImageHandlingService do
  before(:each) do
    allow(ImageHandlingService).to receive(:process_images).and_call_original
  end
 
  let(:visit) { create(:visit) }

  after(:each) do
    ActiveStorage::Blob.all.each(&:purge)
  end

  describe '.process_images' do
    context 'with valid image files' do
      let(:image1) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      let(:image2) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image2.jpg'), 'image/jpeg') }
      let(:image_params) { { images: [image1, image2] } }

      it 'creates new images for the visit' do
        expect {
          result = ImageHandlingService.process_images(visit, image_params)
          expect(result[:success]).to be true
          expect(result[:results].count).to eq(2)
          expect(result[:results].all? { |r| r[:success] }).to be true
        }.to change(visit.images, :count).by(2)
      end

      it 'attaches the files to the created images' do
        result = ImageHandlingService.process_images(visit, image_params)
        expect(result[:success]).to be true
        visit.reload
        expect(visit.images.count).to eq(2)
        expect(visit.images.first.file).to be_attached
        expect(visit.images.last.file).to be_attached
      end

      it 'sets unique filenames' do
        result = ImageHandlingService.process_images(visit, image_params)
        expect(result[:success]).to be true
        visit.reload
        expect(visit.images.count).to eq(2)
        expect(visit.images.first.file.blob.filename.to_s).to match(/^\d{14}_test_image\.jpg$/)
        expect(visit.images.last.file.blob.filename.to_s).to match(/^\d{14}_test_image2\.jpg$/)
        expect(visit.images.first.file.blob.filename).not_to eq(visit.images.last.file.blob.filename)
      end
    end

    context 'with invalid image files' do
      let(:invalid_file) { 'not a file' }
      let(:image_params) { { images: [invalid_file] } }

      it 'logs a warning for non-file objects' do
        expect(Rails.logger).to receive(:warn).with("Skipping non-file object in images array: String")
        result = ImageHandlingService.process_images(visit, image_params)
        expect(result[:success]).to be true
        expect(result[:results].first[:success]).to be false
        expect(result[:results].first[:error]).to eq("Invalid file object: String")
      end

      it 'does not create any images' do
        expect {
          result = ImageHandlingService.process_images(visit, image_params)
          expect(result[:success]).to be true
          expect(result[:results].first[:success]).to be false
        }.not_to change(visit.images, :count)
      end
    end

    context 'when image creation fails' do
      let(:invalid_image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      let(:image_params) { { images: [invalid_image] } }

      before do
        allow_any_instance_of(Image).to receive(:save).and_return(false)
        allow_any_instance_of(Image).to receive(:errors).and_return(double(full_messages: ['Invalid file format']))
        allow(visit).to receive(:save!).and_return(true)
      end

      it 'logs an error message' do
        expect(Rails.logger).to receive(:error).with("Failed to create image: Invalid file format")
        result = ImageHandlingService.process_images(visit, image_params)
        expect(result[:success]).to be true
        expect(result[:results].first[:success]).to be false
        expect(result[:results].first[:error]).to include("Failed to create image: Invalid file format")
      end
    end

    context 'with mixed valid and invalid files' do
      let(:valid_image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      let(:invalid_file) { 'not a file' }
      let(:image_params) { { images: [valid_image, invalid_file] } }

      it 'processes valid files and skips invalid ones' do
        expect(Rails.logger).to receive(:warn).with("Skipping non-file object in images array: String")
        expect {
          result = ImageHandlingService.process_images(visit, image_params)
          expect(result[:success]).to be true
          expect(result[:results].count).to eq(2)
          expect(result[:results].first[:success]).to be true
          expect(result[:results].last[:success]).to be false
        }.to change(visit.images, :count).by(1)
      end
    end

    context 'when an unexpected error occurs' do
      let(:image) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_image.jpg'), 'image/jpeg') }
      let(:image_params) { { images: [image] } }

      it 'catches the error and returns a failure result' do
        allow(visit.images).to receive(:new).and_raise(StandardError.new("Unexpected error"))
        
        expect(Rails.logger).to receive(:error).with(/Error in process_images: Unexpected error/)

        result = ImageHandlingService.process_images(visit, image_params)
        
        expect(result).to eq({ success: false, error: "Unexpected error" })
      end
    end
  end
end
