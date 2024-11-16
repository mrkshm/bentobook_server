require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#notification_dot' do
    let(:user) { create(:user) }
    
    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when user has pending shares' do
      before do
        create(:share, recipient: user, status: :pending)
      end

      it 'returns a notification dot' do
        expect(helper.notification_dot).to have_selector('div.badge.badge-error.badge-xs')
      end
    end

    context 'when user has no pending shares' do
      it 'returns nil' do
        expect(helper.notification_dot).to be_nil
      end
    end

    context 'when user has only accepted shares' do
      before do
        create(:share, recipient: user, status: :accepted)
      end

      it 'returns nil' do
        expect(helper.notification_dot).to be_nil
      end
    end

    context 'when user is not signed in' do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it 'returns nil' do
        expect(helper.notification_dot).to be_nil
      end
    end
  end
end
