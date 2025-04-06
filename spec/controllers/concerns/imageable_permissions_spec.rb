require 'rails_helper'

RSpec.describe ImageablePermissions do
  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new do
      include ImageablePermissions
    end
  end
  
  let(:permissions) { test_class.new }

  before do
    # Create membership to associate user with organization
    create(:membership, user: user, organization: organization)
    # Set Current.organization for the test
    Current.organization = organization
  end

  after do
    # Reset Current.organization after each test
    Current.organization = nil
  end

  describe '#current_user_can_modify_imageable?' do
    context 'when imageable belongs to current organization' do
      it 'returns true for Visit' do
        visit = create(:visit, organization: organization)
        expect(permissions.current_user_can_modify_imageable?(visit)).to be true
      end

      it 'returns true for Contact' do
        contact = create(:contact, organization: organization)
        expect(permissions.current_user_can_modify_imageable?(contact)).to be true
      end

      it 'returns true for Restaurant' do
        restaurant = create(:restaurant, organization: organization)
        expect(permissions.current_user_can_modify_imageable?(restaurant)).to be true
      end
    end

    context 'when imageable belongs to different organization' do
      let(:other_organization) { create(:organization) }

      it 'returns false for Visit' do
        visit = create(:visit, organization: other_organization)
        expect(permissions.current_user_can_modify_imageable?(visit)).to be false
      end

      it 'returns false for Contact' do
        contact = create(:contact, organization: other_organization)
        expect(permissions.current_user_can_modify_imageable?(contact)).to be false
      end

      it 'returns false for Restaurant' do
        restaurant = create(:restaurant, organization: other_organization)
        expect(permissions.current_user_can_modify_imageable?(restaurant)).to be false
      end
    end

    context 'when Current.organization is not set' do
      before do
        Current.organization = nil
      end

      it 'returns false for Visit' do
        visit = create(:visit, organization: organization)
        expect(permissions.current_user_can_modify_imageable?(visit)).to be false
      end
    end

    context 'when imageable is an unsupported type' do
      it 'returns false for nil' do
        expect(permissions.current_user_can_modify_imageable?(nil)).to be false
      end

      it 'returns false for String' do
        expect(permissions.current_user_can_modify_imageable?("some string")).to be false
      end

      it 'returns false for Array' do
        expect(permissions.current_user_can_modify_imageable?([])).to be false
      end

      it 'returns false for Hash' do
        expect(permissions.current_user_can_modify_imageable?({})).to be false
      end

      it 'returns false for custom class' do
        class CustomClass; end
        expect(permissions.current_user_can_modify_imageable?(CustomClass.new)).to be false
      end
    end
  end
end
