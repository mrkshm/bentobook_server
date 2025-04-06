require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # Helper method to debug request
  def debug_request
    puts "\n====== DEBUG ======"
    puts "Request path: #{request.path}"
    puts "Request method: #{request.method}"
    puts "Session: #{session.inspect}"
    puts "Params: #{controller.params.inspect}"
    puts "=================="
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

    it 'confirms the user and redirects to root path' do
      # Generate confirmation token
      raw_token, encrypted_token = Devise.token_generator.generate(User, :confirmation_token)
      user.update!(
        confirmation_token: encrypted_token,
        confirmation_sent_at: Time.current
      )

      # Attempt confirmation
      get :show, params: { confirmation_token: raw_token }
      debug_request

      # Verify the user is confirmed and response is a redirect to root path
      user.reload
      expect(user.confirmed?).to be true
      expect(response).to redirect_to(root_path)
    end
  end
end
