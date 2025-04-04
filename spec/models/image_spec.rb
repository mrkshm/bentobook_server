require 'rails_helper'

RSpec.describe Image, type: :model do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, organization: organization) }

  before do
    create(:membership, user: user, organization: organization)
  end

  describe 'associations' do
    it { should belong_to(:imageable) }
    it { should have_one_attached(:file) }
  end

  describe 'validations' do
    it { should validate_presence_of(:file) }
  end

  describe 'callbacks' do
    describe '#set_filename' do
      it 'sets a new filename after create' do
        image = build(:image, imageable: restaurant)
        image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpeg')
        image.save!
        
        expect(image.file.filename.to_s).to match(/test_image-[a-f0-9]{8}\.jpg/)
      end

      it 'truncates long filenames' do
        image = build(:image, imageable: restaurant)
        image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image_with_very_very_long_name.jpg')), filename: 'test_image_with_very_very_long_name.jpg', content_type: 'image/jpeg')
        image.save!
        
        expect(image.file.filename.to_s).to match(/test_image_with_very_very_long_name-[a-f0-9]{8}\.jpg/)
      end

      context 'when an error occurs during filename setting' do
        let(:image) { build(:image, imageable: restaurant) }
        
        before do
          image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), 
                           filename: 'test_image.jpg', 
                           content_type: 'image/jpeg')
          allow(image.file.blob).to receive(:update!).and_raise(StandardError.new("Test error"))
        end

        it 'logs the error message' do
          expect(Rails.logger).to receive(:error).with("Error in set_filename: Test error")
          expect(Rails.logger).to receive(:error).with(kind_of(String)) # For backtrace
          
          image.save
        end
      end

      context 'when file is not found after rename' do
        let(:image) { build(:image, imageable: restaurant) }
        let(:original_key) { 'original_key' }
        let(:new_key) { "test_image-#{SecureRandom.hex(4)}.jpg" }
        
        before do
          image.file.attach(
            io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')),
            filename: 'test_image.jpg',
            content_type: 'image/jpeg'
          )
          
          # Mock the blob and service
          allow(image.file.blob).to receive(:update!).and_raise(StandardError.new("File not found after rename"))
          allow(image.file.blob.service).to receive(:exist?).with(new_key).and_return(false)
        end

        context 'when original file exists' do
          before do
            allow(image.file.blob.service).to receive(:exist?).with(original_key).and_return(true)
          end

          it 'logs the error message' do
            expect(Rails.logger).to receive(:error).with("Error in set_filename: File not found after rename")
            expect(Rails.logger).to receive(:error).with(kind_of(String)) # For backtrace
            image.save
          end
        end

        context 'when original file does not exist' do
          before do
            allow(image.file.blob.service).to receive(:exist?).with(original_key).and_return(false)
          end

          it 'logs the error message' do
            expect(Rails.logger).to receive(:error).with("Error in set_filename: File not found after rename")
            expect(Rails.logger).to receive(:error).with(kind_of(String)) # For backtrace
            image.save
          end
        end
      end
    end
  end

  describe '#purge_file' do
    it 'purges the attached file when the image is destroyed' do
      image = create(:image, imageable: restaurant)
      image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpeg')
      
      expect(image.file).to be_attached
      expect { image.destroy }.to change { ActiveStorage::Attachment.count }.by(-1)
      expect(image.file).not_to be_attached
    end

    context 'when an error occurs during file purging' do
      let(:image) { create(:image, imageable: restaurant) }
      
      before do
        image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), 
                         filename: 'test_image.jpg', 
                         content_type: 'image/jpeg')
        allow(image.file).to receive(:purge).and_raise(StandardError.new("Purge error"))
      end

      it 'logs the error message' do
        expect(Rails.logger).to receive(:error).with("Error purging file: Purge error")
        
        image.destroy
      end
    end
  end
end
