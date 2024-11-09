require 'rails_helper'
require 'swagger_helper'

RSpec.shared_context "visit image processing stub" do
  before(:each) do
    allow(ImageHandlingService).to receive(:process_images).and_return(true)
  end
end

RSpec.describe 'Visits API', type: :request do
  # Include the shared context only for this describe block
  include_context "visit image processing stub"

  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }
  let(:restaurant) { create(:restaurant, user: user) }
  let!(:visits) { create_list(:visit, 2, user: user) + [create(:visit, :without_price, user: user)] }

  path '/api/v1/visits' do
    get 'Retrieves all visits' do
      tags 'Visits'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'visits found' do
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['visits'].size).to eq(3)
          expect(data).to have_key('pagination')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post 'Creates a visit' do
      tags 'Visits'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :visit, in: :body, schema: {
        type: :object,
        properties: {
          visit: {
            type: :object,
            required: ['date', 'title', 'restaurant_id'],
            properties: {
              date: { type: :string, format: :date },
              title: { type: :string },
              notes: { type: :string },
              restaurant_id: { type: :integer },
              rating: { type: :integer },
              price_paid: { type: :number },
              price_paid_currency: { type: :string },
              contact_ids: { type: :array, items: { type: :integer } }
            }
          }
        }
      }

      response '201', 'visit created with price' do
        let(:Authorization) { "Bearer #{token}" }
        let(:visit) do
          { visit: {
            date: '2023-05-01',
            title: 'Expensive dinner',
            restaurant_id: restaurant.id,
            price_paid: 100.50,
            price_paid_currency: 'EUR'
          } }
        end
      
        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['price_paid']).not_to be_nil
          expect(data['price_paid']['amount']).to eq('100.50')
          expect(data['price_paid']['currency']).to eq('EUR')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        let(:visit) { { date: '' } }  # This should trigger a validation error

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
          expect(data['errors']).to include("Date can't be blank")
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:visit) { { date: '2023-05-01', title: 'Great dinner', restaurant_id: restaurant.id } }
        run_test!
      end

      response '201', 'visit created with price' do
        let(:Authorization) { "Bearer #{token}" }
        let(:visit) do
            { visit: {
                date: '2023-05-01',
                title: 'Expensive dinner',
                restaurant_id: restaurant.id,
                price_paid: 100.50,
                price_paid_currency: 'EUR'
              } }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['price_paid']).not_to be_nil
          expect(data['price_paid']['amount']).to eq('100.50')
          expect(data['price_paid']['currency']).to eq('EUR')
        end
      end

      response '201', 'visit created with zero price' do
        let(:Authorization) { "Bearer #{token}" }
        let(:visit) do
          { visit: {
            date: '2023-05-01',
            title: 'Free dinner',
            restaurant_id: restaurant.id,
            price_paid: 0,
            price_paid_currency: 'EUR'  # Testing with a non-default currency
          } }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['price_paid']).not_to be_nil
          expect(data['price_paid']['amount']).to eq('0.00')
          expect(data['price_paid']['currency']).to eq('EUR')
        end
      end

      response '201', 'visit created with zero price as string' do
        let(:Authorization) { "Bearer #{token}" }
        let(:visit) do
          { visit: {
            date: '2023-05-01',
            title: 'Another free dinner',
            restaurant_id: restaurant.id,
            price_paid: '0'
          } }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['price_paid']).not_to be_nil
          expect(data['price_paid']['amount']).to eq('0.00')
          expect(data['price_paid']['currency']).to eq('USD')  # Default currency
        end
      end

      response '201', 'visit created without price' do
        let(:Authorization) { "Bearer #{token}" }
        let(:visit) do
          {
            date: '2023-05-01',
            title: 'Unknown price dinner',
            restaurant_id: restaurant.id
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['price_paid']).to be_nil
        end
      end

      response '201', 'visit created with price in default currency' do
        let(:Authorization) { "Bearer #{token}" }
        let(:visit) do
          { visit: {
            date: '2023-05-01',
            title: 'Cheap dinner',
            restaurant_id: restaurant.id,
            price_paid: 10.99
          } }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)
          data = JSON.parse(response.body)
          expect(data['price_paid']).not_to be_nil
          expect(data['price_paid']['amount']).to eq('10.99')
          expect(data['price_paid']['currency']).to eq('USD')
        end
      end

      response '422', 'invalid request due to RecordInvalid' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        let(:visit) { { rating: 6 } }  # This should trigger a validation error

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
          expect(data['errors']).to include('Rating must be less than or equal to 5')
        end
      end
    end
  end

  path '/api/v1/visits/{id}' do
    get 'Retrieves a visit' do
      tags 'Visits'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'visit found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(visits.first.id)
        end
      end

      response '404', 'visit not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 'invalid' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { visits.first.id }
        run_test!
      end
    end

    patch 'Updates a visit' do
      tags 'Visits'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :visit, in: :body, schema: {
        type: :object,
        properties: {
          visit: {
            type: :object,
            properties: {
              rating: { type: :integer }
            }
          }
        }
      }

      response '200', 'visit updated' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        let(:visit) { { title: 'Updated dinner' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['title']).to eq('Updated dinner')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        let(:visit) { { date: '' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '404', 'visit not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 'invalid' }
        let(:visit) { { title: 'Updated dinner' } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { visits.first.id }
        let(:visit) { { title: 'Updated dinner' } }
        run_test!
      end

      response '422', 'invalid request due to RecordInvalid' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        let(:visit) { { rating: 6 } }  # Assuming rating has a validation of 1-5

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
          expect(data['errors']).to include('Rating must be less than or equal to 5')
        end
      end

      response '422', 'ActiveRecord::RecordInvalid is rescued' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        let(:visit) { { visit: { title: 'Test Title', date: '2023-05-01' } } }

        before do
          allow_any_instance_of(Visit).to receive(:update).and_raise(ActiveRecord::RecordInvalid.new(Visit.new))
        end

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
          # The exact error message might vary, so we'll just check if it's an array
          expect(data['errors']).to be_an(Array)
        end
      end
    end

    delete 'Deletes a visit' do
      tags 'Visits'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'visit deleted' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { visits.first.id }
        run_test!
      end

      response '404', 'visit not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 'invalid' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { visits.first.id }
        run_test!
      end
    end
  end

  describe 'VisitsController private methods' do
    let(:controller) { Api::V1::VisitsController.new }
    let(:user) { create(:user) }

    describe '#convert_to_money' do
      it 'converts amount to Money object with specified currency' do
        result = controller.send(:convert_to_money, 10.5, 'EUR')
        expect(result).to be_a(Money)
        expect(result.amount).to eq(10.5)
        expect(result.currency.iso_code).to eq('EUR')
      end

      it 'uses USD as default currency if not specified' do
        result = controller.send(:convert_to_money, 20.75, nil)
        expect(result).to be_a(Money)
        expect(result.amount).to eq(20.75)
        expect(result.currency.iso_code).to eq('USD')
      end

      it 'handles string input for amount' do
        result = controller.send(:convert_to_money, '30.25', 'GBP')
        expect(result).to be_a(Money)
        expect(result.amount).to eq(30.25)
        expect(result.currency.iso_code).to eq('GBP')
      end
    end

    describe '#ensure_valid_restaurant' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new)
        allow(controller).to receive(:render)
      end

      context 'when visit params are blank' do
        it 'returns without error' do
          controller.send(:ensure_valid_restaurant)
          expect(controller).not_to have_received(:render)
        end
      end

      context 'when restaurant_id is blank' do
        it 'returns without error' do
          controller.params[:visit] = {}
          controller.send(:ensure_valid_restaurant)
          expect(controller).not_to have_received(:render)
        end
      end

      context 'when restaurant belongs to the user' do
        it 'returns without error' do
          restaurant = create(:restaurant, user: user)
          controller.params[:visit] = { restaurant_id: restaurant.id }
          controller.send(:ensure_valid_restaurant)
          expect(controller).not_to have_received(:render)
        end
      end

      context 'when restaurant does not belong to the user' do
        it 'renders an error' do
          other_user_restaurant = create(:restaurant)
          controller.params[:visit] = { restaurant_id: other_user_restaurant.id }
          controller.send(:ensure_valid_restaurant)
          expect(controller).to have_received(:render).with(
            json: { error: 'Invalid restaurant' },
            status: :unprocessable_entity
          )
        end
      end
    end
  end

  describe 'Image processing' do
    let(:user) { create(:user) }
    let(:token) { generate_jwt_token(user) }
    let(:restaurant) { create(:restaurant, user: user) }
    let(:visit_params) do
      {
        visit: {
          date: '2023-05-01',
          title: 'Visit with images',
          restaurant_id: restaurant.id
        },
        images: ['image1.jpg', 'image2.jpg']
      }
    end

    context 'when image processing succeeds' do
      before do
        allow(ImageHandlingService).to receive(:process_images).and_return(true)
      end

      it 'creates a visit with images' do
        post '/api/v1/visits', params: visit_params, headers: { 'Authorization' => "Bearer #{token}" }
        
        expect(response).to have_http_status(:created)
        expect(ImageHandlingService).to have_received(:process_images)
      end
    end

    context 'when image processing fails' do
      before do
        allow(ImageHandlingService).to receive(:process_images).and_raise(StandardError.new('Image processing failed'))
      end

      it 'returns an error message and does not create the visit' do
        expect {
          post '/api/v1/visits', params: visit_params, headers: { 'Authorization' => "Bearer #{token}" }
        }.not_to change(Visit, :count)
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Image processing failed' })
      end
    end
  end
end
