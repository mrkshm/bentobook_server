require 'rails_helper'

RSpec.describe Api::V1::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:valid_attributes) { { email: 'test@example.com', password: 'password123', password_confirmation: 'password123' } }
    let(:invalid_attributes) { { email: 'invalid_email', password: 'short', password_confirmation: 'mismatch' } }

    context 'with valid parameters' do
      it 'creates a new User' do
        expect {
          post :create, params: { user: valid_attributes }, format: :json
        }.to change(User, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post :create, params: { user: valid_attributes }, format: :json
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        data = JSON.parse(json_response['data'])

        expect(json_response['status']).to include('code' => 200, 'message' => 'Signed up successfully.')
        expect(data).to include('email' => 'test@example.com')
        expect(json_response['token']).to be_a(String)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect {
          post :create, params: { user: invalid_attributes }, format: :json
        }.to change(User, :count).by(0)
      end

      it 'renders a JSON response with errors' do
        post :create, params: { user: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include(
          'status' => include('message' => "User couldn't be created successfully."),
          'errors' => be_present
        )
      end
    end

    context 'when user is created but not activated' do
      before do
        allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
      end

      it 'renders a JSON response with unauthorized status' do
        post :create, params: { user: valid_attributes }, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include(
          'status' => include('code' => 401, 'message' => 'User created but not activated'),
          'errors' => include('User is not activated')
        )
      end
    end
  end
end
