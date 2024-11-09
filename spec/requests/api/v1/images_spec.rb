require 'swagger_helper'

RSpec.describe 'Api::V1::Images', type: :request do
  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:restaurant) { create(:restaurant, user: user) }

  path '/api/v1/restaurants/{restaurant_id}/images' do
    post 'Creates an image' do
      tags 'Images'
      consumes 'multipart/form-data'
      produces 'application/json'
      security [bearer_auth: []]
      
      parameter name: :restaurant_id, in: :path, type: :string
      parameter name: :file, in: :formData, type: :file, required: true

      response '201', 'image created' do
        let(:restaurant_id) { restaurant.id }
        let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_image.jpg'), 'image/jpeg') }
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Image uploaded successfully')
          expect(data['image']).to include('id', 'url', 'filename', 'content_type')
        end
      end

      response '403', 'forbidden' do
        let(:other_restaurant) { create(:restaurant) }
        let(:restaurant_id) { other_restaurant.id }
        let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_image.jpg'), 'image/jpeg') }
        let(:Authorization) { "Bearer #{token}" }
        
        run_test!
      end
    end
  end

  describe 'Image upload validations' do
    let(:upload_path) { "/api/v1/restaurants/#{restaurant.id}/images" }
    
    context 'with invalid parameters' do
      it 'returns unprocessable entity when file is missing' do
        post upload_path, 
             headers: auth_headers,
             params: { restaurant_id: restaurant.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end

      it 'returns not found for non-existent restaurant' do
        post "/api/v1/restaurants/0/images",
             headers: auth_headers,
             params: {
               file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_image.jpg'), 'image/jpeg')
             }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']).to include('Resource not found')
      end
    end

    context 'with authentication issues' do
      it 'returns unauthorized without token' do
        post upload_path,
             params: {
               file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_image.jpg'), 'image/jpeg')
             }

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized with invalid token' do
        post upload_path,
             headers: { 'Authorization' => 'Bearer invalid_token' },
             params: {
               file: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test_image.jpg'), 'image/jpeg')
             }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
