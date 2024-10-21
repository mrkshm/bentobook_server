require 'rails_helper'

RSpec.describe ApiControllerConcern, type: :controller do
  controller(ApplicationController) do
    include ApiControllerConcern

    def test_render_error
      render_error('Test error message', :unprocessable_entity, { field: ['is invalid'] })
    end
  end

  before do
    routes.draw { get 'test_render_error' => 'anonymous#test_render_error' }
  end

  describe '#render_error' do
    it 'renders error response with message and status' do
      get :test_render_error
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Test error message')
      expect(json_response['errors']).to eq({ 'field' => ['is invalid'] })
    end

    it 'renders error response without errors field when not provided' do
      controller.send(:render_error, 'Another error', :bad_request)
      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('Another error')
      expect(json_response).not_to have_key('errors')
    end
  end
end

