require 'rails_helper'

RSpec.describe UserSession, type: :model do
  subject { create(:user_session) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:jti) }
    it { should validate_uniqueness_of(:jti) }
    it { should validate_presence_of(:client_name) }
    it { should validate_presence_of(:last_used_at) }
  end

  describe 'callbacks' do
    let(:user_session) { build(:user_session) }

    it 'sets last_used_at before validation on create' do
      travel_to Time.current do
        user_session.valid?
        expect(user_session.last_used_at).to eq(Time.current)
      end
    end

    it 'generates jti before create' do
      user_session.valid?
      expect(user_session.jti).to be_present
      expect(user_session.jti).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/)
    end
  end

  describe 'scopes' do
    let!(:active_session) { create(:user_session, active: true) }
    let!(:inactive_session) { create(:user_session, active: false) }

    describe '.active' do
      it 'returns only active sessions' do
        expect(described_class.active).to contain_exactly(active_session)
      end
    end

    describe '.inactive' do
      it 'returns only inactive sessions' do
        expect(described_class.inactive).to contain_exactly(inactive_session)
      end
    end
  end

  describe '.revoke!' do
    let!(:user_session) { create(:user_session) }

    it 'marks the session as inactive' do
      described_class.revoke!(user_session.jti)
      expect(user_session.reload).not_to be_active
    end

    it 'raises error for non-existent jti' do
      expect { described_class.revoke!('non-existent') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#touch_last_used!' do
    let(:user_session) { create(:user_session, last_used_at: 1.hour.ago) }

    it 'updates last_used_at to current time' do
      travel_to Time.current do
        user_session.touch_last_used!
        expect(user_session.reload.last_used_at).to eq(Time.current)
      end
    end
  end
end
