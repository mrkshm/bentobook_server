require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#after_confirmation_path_for' do
    let(:user) { create(:user, :unconfirmed) }

    it 'signs in the user and returns root path' do
      path = controller.send(:after_confirmation_path_for, :user, user)

      expect(controller.current_user).to eq(user)
      expect(path).to eq(root_path)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user, :unconfirmed) }

    it 'confirms the user successfully' do
      # Generate confirmation token
      raw_token, encrypted_token = Devise.token_generator.generate(User, :confirmation_token)
      user.update!(
        confirmation_token: encrypted_token,
        confirmation_sent_at: Time.current
      )

      # Attempt confirmation
      get :show, params: { confirmation_token: raw_token }

      # Verify the user is confirmed and response is successful
      user.reload
      expect(user.confirmed?).to be true
      expect(response).to be_successful
    end
  end
end
