require 'rails_helper'

RSpec.describe Image, type: :model do
  let(:user) { create(:user) }
  let(:restaurant) { create(:restaurant, user: user) }

  describe 'associations' do
    it { should belong_to(:imageable) }
    it { should have_one_attached(:file) }
  end

  describe 'validations' do
    it { should validate_presence_of(:imageable) }
    it { should validate_presence_of(:file) }
  end

  describe 'callbacks' do
    describe '#set_filename' do
      it 'sets a new filename after create' do
        image = build(:image, imageable: restaurant)
        image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test_image.jpg', content_type: 'image/jpeg')
        image.save!
        
        expect(image.file.filename.to_s).to match(/\d{14}_test_image\.jpg/)
      end

      it 'truncates long filenames' do
        image = build(:image, imageable: restaurant)
        image.file.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image_with_very_very_long_name.jpg')), filename: 'test_image_with_very_very_long_name.jpg', content_type: 'image/jpeg')
        image.save!
        
        expect(image.file.filename.to_s).to match(/\d{14}_test_image_w\.jpg/)
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
  end
end
