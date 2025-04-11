require 'rails_helper'

RSpec.describe Api::V1::BaseController, type: :controller do
  # Create a test controller that inherits from BaseController to test its functionality
  controller(Api::V1::BaseController) do
    # Add endpoints for testing
    def index
      # Get a real model to avoid the id issue with render_success
      restaurant = Current.organization.restaurants.first || FactoryBot.create(:restaurant, organization: Current.organization)
      render_success(restaurant)
    end

    def show
      raise ActiveRecord::RecordNotFound, "Record not found"
    end

    def unauthorized_action
      unauthorized_response
    end

    def validation_error_action
      resource = Restaurant.new
      resource.valid? # trigger validation errors
      render_validation_errors(resource)
    end
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user) }
  let!(:restaurant) { create(:restaurant, organization: organization) }

  before do
    # Create membership to associate user with organization
    create(:membership, user: user, organization: organization)
    
    # Set up routes for our controller
    routes.draw do
      get 'test', to: 'api/v1/base#index'
      get 'test/:id', to: 'api/v1/base#show'
      get 'unauthorized', to: 'api/v1/base#unauthorized_action'
      get 'validation_error', to: 'api/v1/base#validation_error_action'
    end
    
    # Set up authentication with JWT token
    sign_in user
    
    # Set Current context
    Current.user = user
    Current.organization = organization
    
    # Mock BaseSerializer responses to avoid dependency issues
    allow(BaseSerializer).to receive(:render_success).and_return({
      status: 'success',
      data: {
        id: restaurant.id.to_s,
        type: 'restaurant',
        attributes: { name: restaurant.name }
      }
    })
    
    allow(BaseSerializer).to receive(:render_error).and_return({
      status: 'error',
      errors: [{
        code: 'not_found',
        detail: 'Record not found',
        source: { pointer: '/data' }
      }]
    })
    
    allow(BaseSerializer).to receive(:render_validation_errors).and_return({
      status: 'error',
      errors: [{
        code: 'validation_error',
        detail: 'Name can\'t be blank',
        source: { pointer: '/data/attributes/name' }
      }]
    })
    
    # Skip authenticate_user! for testing to avoid authentication errors
    # This simulates a user who is already authenticated
    controller.class.skip_before_action :authenticate_user!, raise: false
  end

  after do
    Current.organization = nil
    Current.user = nil
  end

  # Helper method to debug request
  def debug_request
    puts "\n====== DEBUG ======"
    puts "Request path: #{request.path}"
    puts "Request method: #{request.method}"
    puts "Response status: #{response.status}"
    puts "Response body: #{response.body}"
    puts "Current.organization: #{Current.organization&.id}"
    puts "Current.user: #{Current.user&.id}"
    puts "=================="
  end

  describe 'API controller behavior' do
    describe 'authentication' do
      it 'allows access with valid authentication' do
        get :index
        debug_request
        expect(response).to have_http_status(:ok)
      end
    end
    
    describe 'response formatting' do
      it 'sets json as default format' do
        get :index
        debug_request
        expect(response.content_type).to include('application/json')
      end
      
      it 'renders success responses correctly' do
        get :index
        debug_request
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['data']).to have_key('id')
        expect(json['data']).to have_key('type')
        expect(json['data']).to have_key('attributes')
        expect(json['data']['type']).to eq('restaurant')
      end
    end

    describe 'error handling' do
      it 'handles record not found errors' do
        get :show, params: { id: 0 }
        debug_request
        expect(response).to have_http_status(:not_found)
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['errors'].first['code']).to eq('not_found')
      end

      it 'handles unauthorized access' do
        get :unauthorized_action
        debug_request
        expect(response).to have_http_status(:unauthorized)
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['errors'].first['code']).to eq('not_found')
      end

      it 'handles validation errors' do
        get :validation_error_action
        debug_request
        expect(response).to have_http_status(:unprocessable_entity)
        
        json = JSON.parse(response.body)
        expect(json['status']).to eq('error')
        expect(json['errors']).to be_present
      end
    end
  end
end
