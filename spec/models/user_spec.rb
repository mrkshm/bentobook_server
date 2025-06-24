# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string
#  language               :string           default("en")
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  theme                  :string           default("light")
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { should have_many(:allowlisted_jwts).dependent(:destroy) }
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:organizations).through(:memberships) }
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
          }.not_to change { [ User.count, Organization.count ] }
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

  describe 'attributes' do
    it 'has default values for theme' do
      user = User.new
      expect(user.theme).to eq('light')
    end

    it 'has default values for language' do
      user = User.new
      expect(user.language).to eq('en')
    end
  end

  describe 'validations for preferences' do
    it { should validate_length_of(:first_name).is_at_most(50).allow_blank }
    it { should validate_length_of(:last_name).is_at_most(50).allow_blank }
  end

  describe 'name methods' do
    describe '#full_name' do
      it 'returns first and last name combined' do
        user = build(:user, first_name: 'Jane', last_name: 'Smith')
        expect(user.full_name).to eq('Jane Smith')
      end

      it 'returns just first name if last name is blank' do
        user = build(:user, first_name: 'Jane', last_name: nil)
        expect(user.full_name).to eq('Jane')
      end

      it 'returns just last name if first name is blank' do
        user = build(:user, first_name: nil, last_name: 'Smith')
        expect(user.full_name).to eq('Smith')
      end

      it 'returns nil if both names are blank' do
        user = build(:user, first_name: nil, last_name: nil)
        expect(user.full_name).to be_nil
      end
    end

    describe '#display_name' do
      it 'returns full name when available' do
        user = build(:user, first_name: 'Jane', last_name: 'Smith')
        expect(user.display_name).to eq('Jane Smith')
      end

      it 'returns email when full name is not available' do
        user = build(:user, first_name: nil, last_name: nil, email: 'jane@example.com')
        expect(user.display_name).to eq('jane@example.com')
      end
    end
  end
end
