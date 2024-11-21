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
      freeze_time do
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
      freeze_time do
        old_time = user_session.last_used_at
        user_session.touch_last_used!
        expect(user_session.reload.last_used_at).to be > old_time
      end
    end
  end

  describe 'token validation' do
    let(:user) { create(:user) }
    let(:user_session) { create(:user_session, user: user, last_used_at: 1.hour.ago) }

    describe '.validate_token' do
      let(:valid_payload) do
        {
          'jti' => user_session.jti,
          'sub' => user.id,
          'exp' => 24.hours.from_now.to_i,
          'client' => { 'name' => user_session.client_name }
        }
      end

      it 'returns true for valid token payload' do
        expect(described_class.validate_token(valid_payload)).to be true
      end

      it 'returns false for revoked session' do
        user_session.update!(active: false)
        expect(described_class.validate_token(valid_payload)).to be false
      end

      it 'returns false for non-existent session' do
        payload_with_invalid_jti = valid_payload.merge('jti' => 'invalid-jti')
        expect(described_class.validate_token(payload_with_invalid_jti)).to be false
      end

      it 'returns false for mismatched user' do
        other_user = create(:user)
        payload_with_wrong_user = valid_payload.merge('sub' => other_user.id)
        expect(described_class.validate_token(payload_with_wrong_user)).to be false
      end

      it 'updates last_used_at when validating token' do
        initial_time = user_session.last_used_at
        travel(1.minute)
        described_class.validate_token(valid_payload)
        expect(user_session.reload.last_used_at).to be > initial_time
      end
    end
  end

  describe 'session management' do
    let(:user) { create(:user) }

    describe '.create_session' do
      let(:client_info) { { name: 'Test Browser', platform: 'web' } }

      it 'creates a new active session' do
        expect {
          session = described_class.create_session(user, client_info)
          expect(session).to be_persisted
          expect(session.active).to be true
          expect(session.client_name).to eq(client_info[:name])
          expect(session.user).to eq(user)
        }.to change(described_class, :count).by(1)
      end

      it 'handles multiple active sessions for the same user' do
        first_session = described_class.create_session(user, { name: 'First Device' })
        second_session = described_class.create_session(user, { name: 'Second Device' })

        expect(first_session).to be_active
        expect(second_session).to be_active
        expect(user.user_sessions.active.count).to eq(2)
      end
    end

    describe '#revoke!' do
      let!(:user_session) { create(:user_session, user: user) }

      it 'marks the session as inactive' do
        expect {
          user_session.revoke!
        }.to change { user_session.active }.from(true).to(false)
      end

      it 'only affects the current session' do
        other_session = create(:user_session, user: user)
        user_session.revoke!

        expect(user_session.reload).not_to be_active
        expect(other_session.reload).to be_active
      end
    end
  end
end
