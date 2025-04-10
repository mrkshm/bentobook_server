require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#notification_dot' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before do
      # Create a controller instance and add it to the view context
      controller = ApplicationController.new
      # Set the current_organization method on the controller instance
      def helper.current_organization
        @current_organization
      end
      # Set the instance variable directly on the helper
      helper.instance_variable_set(:@current_organization, organization)
    end

    context 'when organization has pending incoming shares' do
      before do
        create(:share, target_organization: organization, status: :pending)
      end

      it 'returns a notification dot' do
        expect(helper.notification_dot).to have_selector('div.badge.badge-error.badge-xs')
      end
    end

    context 'when organization has no pending shares' do
      it 'returns nil' do
        expect(helper.notification_dot).to be_nil
      end
    end

    context 'when organization has only accepted shares' do
      before do
        create(:share, target_organization: organization, status: :accepted)
      end

      it 'returns nil' do
        expect(helper.notification_dot).to be_nil
      end
    end

    context 'when current_organization is nil' do
      before do
        helper.instance_variable_set(:@current_organization, nil)
      end

      it 'returns nil' do
        expect(helper.notification_dot).to be_nil
      end
    end
  end
end
