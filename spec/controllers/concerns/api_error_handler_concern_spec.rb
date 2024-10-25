require 'rails_helper'

RSpec.describe ApiErrorHandlerConcern do
  # Create a test controller that includes our concern
  controller(ActionController::API) do
    include ApiErrorHandlerConcern

    def test_unprocessable_entity
      # Create an invalid record to raise ActiveRecord::RecordInvalid
      user = User.new
      user.save!
    end
  end

  # Add our test route
  before do
    routes.draw { get 'test_unprocessable_entity' => 'anonymous#test_unprocessable_entity' }
  end

  describe 'error handling' do
    describe '#unprocessable_entity' do
      it 'renders error messages with 422 status' do
        get :test_unprocessable_entity
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('errors')
        expect(JSON.parse(response.body)['errors']).to be_an(Array)
      end
    end
  end
end

