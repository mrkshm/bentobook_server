require 'rails_helper'

RSpec.describe ImageablePermissions do
  let(:user) { create(:user) }
  
  # Create a test class that includes the concern
  let(:test_class) do
    Class.new do
      include ImageablePermissions
      
      attr_reader :current_user
      
      def initialize(current_user)
        @current_user = current_user
      end
    end
  end
  
  let(:permissions) { test_class.new(user) }

  describe '#current_user_can_modify_imageable?' do
    context 'when imageable belongs to current user' do
      it 'returns true for Visit' do
        visit = create(:visit, user: user)
        expect(permissions.current_user_can_modify_imageable?(visit)).to be true
      end

      it 'returns true for Contact' do
        contact = create(:contact, user: user)
        expect(permissions.current_user_can_modify_imageable?(contact)).to be true
      end

      it 'returns true for Restaurant' do
        restaurant = create(:restaurant, user: user)
        expect(permissions.current_user_can_modify_imageable?(restaurant)).to be true
      end
    end

    context 'when imageable belongs to different user' do
      let(:other_user) { create(:user) }

      it 'returns false for Visit' do
        visit = create(:visit, user: other_user)
        expect(permissions.current_user_can_modify_imageable?(visit)).to be false
      end

      it 'returns false for Contact' do
        contact = create(:contact, user: other_user)
        expect(permissions.current_user_can_modify_imageable?(contact)).to be false
      end

      it 'returns false for Restaurant' do
        restaurant = create(:restaurant, user: other_user)
        expect(permissions.current_user_can_modify_imageable?(restaurant)).to be false
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
