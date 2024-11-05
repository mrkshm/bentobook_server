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
end
