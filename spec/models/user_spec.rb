require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:restaurants) }
    it { should have_many(:google_restaurants).through(:restaurants) }
    it { should have_many(:memberships) }
    it { should have_many(:organizations).through(:memberships) }
    it { should have_many(:contacts) }
    it { should have_many(:visits) }
    it { should have_many(:images).dependent(:destroy) }
    it { should have_one(:profile).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe 'callbacks' do
    it 'creates a profile after user creation' do
      user = create(:user)
      expect(user.reload.profile).to be_present
    end
  end

  describe 'instance methods' do
    describe '#confirmation_required?' do
      it 'returns true in production environment' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        user = build(:user)
        expect(user.confirmation_required?).to be true
      end

      it 'returns false in development environment' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        user = build(:user)
        expect(user.confirmation_required?).to be false
      end
    end

    describe '#all_tags' do
      it 'returns all tags for user restaurants' do
        user = create(:user)
        create(:restaurant, user: user, tag_list: ['italian', 'pizza'])
        create(:restaurant, user: user, tag_list: ['chinese', 'noodles'])
        
        expect(user.all_tags.map(&:name)).to match_array(['italian', 'pizza', 'chinese', 'noodles'])
      end

      it 'returns an empty array if user has no restaurants' do
        user = create(:user)
        expect(user.all_tags).to be_empty
      end

      it 'does not return duplicate tags' do
        user = create(:user)
        create(:restaurant, user: user, tag_list: ['italian', 'pizza'])
        create(:restaurant, user: user, tag_list: ['italian', 'pasta'])
        
        expect(user.all_tags.map(&:name)).to match_array(['italian', 'pizza', 'pasta'])
      end
    end

    describe '#lock_access!' do
      it 'does not lock access in development environment' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        user = create(:user)
        expect { user.lock_access! }.not_to change { user.access_locked? }
      end

      it 'locks access in production environment' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        user = create(:user)
        expect { user.lock_access! }.to change { user.access_locked? }.from(false).to(true)
      end
    end

    describe '#jwt_revoked?' do
      let(:user) { create(:user) }
      let(:payload) { { 'jti' => SecureRandom.uuid, 'exp' => 1.hour.from_now.to_i } }

      it 'returns false for any token (no revocation)' do
        expect(user.send(:jwt_revoked?, payload, user)).to be false
      end

      it 'accepts payload and user parameters' do
        expect { user.send(:jwt_revoked?, payload, user) }.not_to raise_error
      end

      it 'handles different payload formats' do
        different_payload = { 'sub' => user.id, 'iat' => Time.current.to_i }
        expect(user.send(:jwt_revoked?, different_payload, user)).to be false
      end

      it 'handles nil payload' do
        expect(user.send(:jwt_revoked?, nil, user)).to be false
      end
    end
  end
end
