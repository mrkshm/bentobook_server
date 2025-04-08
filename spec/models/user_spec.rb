require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { should have_many(:allowlisted_jwts).dependent(:destroy) }
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:organizations).through(:memberships) }
    it { should have_one(:profile).dependent(:destroy) }
    # Removed cross-organization associations
    # These are now accessed through organizations
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'creates an organization for the user' do
        user = create(:user)
        expect(user.organizations.count).to eq(1)
      end

      it 'creates a membership for the user in the new organization' do
        user = create(:user)
        expect(user.memberships.count).to eq(1)
      end

      it 'creates a profile for the user' do
        user = create(:user)
        expect(user.profile).to be_present
      end

      context 'when organization creation fails' do
        let(:logger) { instance_double(ActiveSupport::Logger) }
        
        before do
          allow(Rails).to receive(:logger).and_return(logger)
          allow(logger).to receive(:error)
          allow_any_instance_of(Organization).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Organization.new))
        end

        it 'logs the error and re-raises it' do
          user = build(:user)
          expect(logger).to receive(:error).with(/Failed to create organization for user #{user.id}/)
          expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'rolls back user creation' do
          expect {
            begin
              create(:user)
            rescue ActiveRecord::RecordInvalid
              nil
            end
          }.not_to change(User, :count)
        end
      end

      context 'when membership creation fails' do
        let(:logger) { instance_double(ActiveSupport::Logger) }
        
        before do
          allow(Rails).to receive(:logger).and_return(logger)
          allow(logger).to receive(:error)
          allow_any_instance_of(Membership).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(Membership.new))
        end

        it 'logs the error and re-raises it' do
          user = build(:user)
          expect(logger).to receive(:error).with(/Failed to create organization for user #{user.id}/)
          expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'rolls back user and organization creation' do
          expect {
            begin
              create(:user)
            rescue ActiveRecord::RecordInvalid
              nil
            end
          }.not_to change { [User.count, Organization.count] }
        end
      end
    end
  end

  describe 'JWT handling' do
    describe '#on_jwt_dispatch' do
      it 'adds client_info to the payload' do
        user = create(:user)
        payload = {}
        user.on_jwt_dispatch(nil, payload)
        expect(payload['client_info']).to eq(user.current_sign_in_ip)
      end
    end
  end

  describe 'development convenience methods' do
    describe '#confirmation_required?' do
      context 'in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        end

        it 'returns true' do
          expect(subject.confirmation_required?).to be true
        end
      end

      context 'in non-production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        end

        it 'returns false' do
          expect(subject.confirmation_required?).to be false
        end
      end
    end

    describe '#lock_access!' do
      it 'returns nil in development' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        expect(subject.lock_access!).to be_nil
      end

      it 'delegates to Devise in production' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        expect_any_instance_of(Devise::Models::Lockable).to receive(:lock_access!)
        subject.lock_access!
      end
    end
  end
end
