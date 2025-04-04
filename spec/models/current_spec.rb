require 'rails_helper'

RSpec.describe Current, type: :model do
  # Reset Current attributes before each test
  before { Current.reset }
  after { Current.reset }

  describe 'attributes' do
    it 'has user attribute' do
      expect(Current.new).to respond_to(:user)
    end

    it 'has organization attribute' do
      expect(Current.new).to respond_to(:organization)
    end
  end

  describe '.organization!' do
    it 'returns the organization when set' do
      organization = create(:organization)
      Current.organization = organization
      expect(Current.organization!).to eq(organization)
    end

    it 'raises an error when no organization is set' do
      Current.organization = nil
      expect { Current.organization! }.to raise_error("No organization context set")
    end
  end

  describe '.organization=' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before do
      Current.reset
      Current.user = user
    end

    after do
      Current.reset
    end

    context 'when user is set' do
      context 'when organization belongs to user' do
        before do
          create(:membership, user: user, organization: organization)
        end

        it 'sets the organization' do
          Current.organization = organization
          expect(Current.organization).to eq(organization)
        end
      end

      context 'when organization does not belong to user' do
        it 'raises an error' do
          expect { Current.organization = organization }
            .to raise_error("Organization must belong to current user")
        end
      end
    end

    context 'when user is not set' do
      before do
        Current.reset
      end

      it 'allows setting any organization' do
        Current.organization = organization
        expect(Current.organization).to eq(organization)
      end
    end

    context 'when organization is nil' do
      it 'allows setting nil' do
        Current.organization = nil
        expect(Current.organization).to be_nil
      end
    end
  end

  describe 'resets' do
    it 'resets organization when user is reset' do
      # Start with a clean state
      Current.reset

      # Set up initial state
      user1 = create(:user)
      organization = create(:organization)
      create(:membership, user: user1, organization: organization)

      # Set initial user and organization
      Current.user = user1
      Current.organization = organization
      expect(Current.organization).to eq(organization)

      # Set user to nil - this should trigger the reset callback
      Current.user = nil

      # Verify organization was reset
      expect(Current.organization).to be_nil
    end
  end
end
