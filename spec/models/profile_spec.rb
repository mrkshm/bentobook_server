require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one_attached(:avatar) }
  end

  describe 'validations' do
    subject { create(:profile) } 
    it { should validate_uniqueness_of(:username).allow_blank }
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
    it 'returns nil when no avatar is attached' do
      profile = build(:profile)
      expect(profile.avatar_url).to be_nil
    end

    it 'returns a filename when an avatar is attached' do
      profile = create(:profile)
      profile.avatar.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'avatar.jpg')), filename: 'avatar.jpg', content_type: 'image/jpeg')
      expect(profile.avatar_url).to eq('avatar.jpg')
    end
  end
end
