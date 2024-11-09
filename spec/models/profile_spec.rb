require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one_attached(:avatar) }
  end

  describe 'validations' do
    subject { create(:profile) } 
    it { should validate_uniqueness_of(:username).allow_blank }
    it { should validate_length_of(:first_name).is_at_most(50) }
    it { should validate_length_of(:last_name).is_at_most(50) }
    it { should validate_inclusion_of(:preferred_theme).in_array(Profile::VALID_THEMES) }
    it { should validate_inclusion_of(:preferred_language).in_array(Profile::VALID_LANGUAGES) }
  end

  describe '#full_name' do
    it 'returns the full name when both first and last name are present' do
      profile = build(:profile, first_name: 'John', last_name: 'Doe')
      expect(profile.full_name).to eq('John Doe')
    end

    it 'returns only the first name when last name is blank' do
      profile = build(:profile, first_name: 'John', last_name: '')
      expect(profile.full_name).to eq('John')
    end

    it 'returns only the last name when first name is blank' do
      profile = build(:profile, first_name: '', last_name: 'Doe')
      expect(profile.full_name).to eq('Doe')
    end

    it 'returns nil when both names are blank' do
      profile = build(:profile, first_name: '', last_name: '')
      expect(profile.full_name).to be_nil
    end
  end

  describe '#display_name' do
    it 'returns the username when present' do
      profile = build(:profile, username: 'johndoe')
      expect(profile.display_name).to eq('johndoe')
    end

    it 'returns the full name when username is blank and full name is present' do
      profile = build(:profile, username: '', first_name: 'John', last_name: 'Doe')
      expect(profile.display_name).to eq('John Doe')
    end

    it 'returns the email username when username and full name are blank' do
      user = create(:user, email: 'john.doe@example.com')
      profile = build(:profile, user: user, username: '', first_name: '', last_name: '')
      expect(profile.display_name).to eq('john.doe')
    end
  end

  describe '#avatar_url' do
    let(:profile) { create(:profile) }
    let(:host) { 'example.com' }

    before do
      Rails.application.config.action_mailer.default_url_options = { host: host }
    end

    context 'when avatar is attached' do
      before do
        profile.avatar.attach(
          io: File.open(Rails.root.join('spec/fixtures/test_image.jpg')),
          filename: 'test_image.jpg',
          content_type: 'image/jpeg'
        )
      end

      it 'returns the avatar url' do
        expect(profile.avatar_url).to include(host)
        expect(profile.avatar_url).to include('test_image.jpg')
      end

      it 'returns nil when url generation fails' do
        allow(Rails.application.routes.url_helpers).to receive(:rails_blob_url).and_raise(StandardError.new('Test error'))
        
        expect(Rails.logger).to receive(:error).with(/Error generating avatar URL: Test error/)
        expect(profile.avatar_url).to be_nil
      end
    end

    context 'when avatar is not attached' do
      it 'returns nil' do
        expect(profile.avatar_url).to be_nil
      end
    end
  end
end
