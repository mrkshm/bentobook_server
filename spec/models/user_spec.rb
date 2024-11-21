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
    it { should have_many(:lists).dependent(:destroy) }
    it { should have_many(:shares).with_foreign_key(:recipient_id) }
    it { should have_many(:created_shares).class_name('Share').with_foreign_key(:creator_id) }
    it { should have_many(:shared_lists).through(:shares).source(:shareable).conditions(shares: { shareable_type: 'List' }) }
    it { should have_many(:user_sessions).dependent(:destroy) }
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

    describe 'session management' do
      let(:user) { create(:user) }
      let(:session_params) do
        {
          client_name: 'test_client',
          ip_address: '127.0.0.1',
          user_agent: 'Mozilla/5.0'
        }
      end

      describe '#create_session!' do
        it 'creates a new user session' do
          expect {
            user.create_session!(**session_params)
          }.to change(user.user_sessions, :count).by(1)
        end

        it 'sets the correct attributes' do
          session = user.create_session!(**session_params)
          expect(session.client_name).to eq('test_client')
          expect(session.ip_address).to eq('127.0.0.1')
          expect(session.user_agent).to eq('Mozilla/5.0')
          expect(session).to be_active
        end
      end

      describe '#active_sessions' do
        before do
          2.times { user.create_session!(**session_params) }
          user.user_sessions.last.update!(active: false)
        end

        it 'returns only active sessions' do
          expect(user.active_sessions.count).to eq(1)
          expect(user.active_sessions.first).to be_active
        end
      end

      describe '#revoke_session!' do
        it 'revokes the specified session' do
          session = user.create_session!(**session_params)
          user.revoke_session!(session.jti)
          expect(session.reload).not_to be_active
        end
      end

      describe '#revoke_all_sessions!' do
        it 'revokes all active sessions' do
          3.times { user.create_session!(**session_params) }
          user.revoke_all_sessions!
          expect(user.active_sessions).to be_empty
        end
      end
    end

    describe 'shared lists' do
      let(:user) { create(:user) }
      let(:list) { create(:list) }

      before do
        create(:share, shareable: list, recipient: user, status: :pending)
        create(:share, shareable: create(:list), recipient: user, status: :accepted)
      end

      describe '#shared_lists' do
        describe '#pending' do
          it 'returns only pending shared lists' do
            expect(user.shared_lists.pending.count).to eq(1)
          end
        end

        describe '#accepted' do
          it 'returns only accepted shared lists' do
            expect(user.shared_lists.accepted.count).to eq(1)
          end
        end
      end
    end

    describe '#jwt_revoked?' do
      let(:user) { create(:user) }
      let(:session) { user.create_session!(client_name: 'test') }
      let(:payload) { { 'jti' => session.jti } }

      it 'returns false for active sessions' do
        expect(user.send(:jwt_revoked?, payload, user)).to be false
      end

      it 'returns true for revoked sessions' do
        session.update!(active: false)
        expect(user.send(:jwt_revoked?, payload, user)).to be true
      end

      it 'returns false for unknown JTIs' do
        expect(user.send(:jwt_revoked?, { 'jti' => 'unknown' }, user)).to be false
      end
    end
  end
end
