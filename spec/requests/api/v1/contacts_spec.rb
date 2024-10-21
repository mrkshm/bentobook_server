# spec/requests/api/v1/contacts_spec.rb
require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Contacts API', type: :request do
  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }
  let!(:contacts) { create_list(:contact, 3, user: user) }

  path '/api/v1/contacts' do
    get 'Retrieves all contacts' do
      tags 'Contacts'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'contacts found' do
        let(:Authorization) { "Bearer #{token}" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['contacts'].size).to eq(3)
          expect(data).to have_key('pagination')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        run_test!
      end
    end

    post 'Creates a contact' do
      tags 'Contacts'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :contact, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          city: { type: :string },
          country: { type: :string },
          phone: { type: :string },
          notes: { type: :string }
        },
        required: ['name', 'email']
      }

      response '201', 'contact created' do
        let(:Authorization) { "Bearer #{token}" }
        let(:contact) { { name: 'John Doe', email: 'john@example.com' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('John Doe')
          expect(data['email']).to eq('john@example.com')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:contact) { { name: '' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:contact) { { name: 'John Doe', email: 'john@example.com' } }
        run_test!
      end
    end
  end

  path '/api/v1/contacts/{id}' do
    get 'Retrieves a contact' do
      tags 'Contacts'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '200', 'contact found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { contacts.first.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['id']).to eq(contacts.first.id)
        end
      end

      response '404', 'contact not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 'invalid' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { contacts.first.id }
        run_test!
      end
    end

    patch 'Updates a contact' do
      tags 'Contacts'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string
      parameter name: :contact, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          city: { type: :string },
          country: { type: :string },
          phone: { type: :string },
          notes: { type: :string }
        }
      }

      response '200', 'contact updated' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { contacts.first.id }
        let(:contact) { { name: 'Jane Doe' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Jane Doe')
        end
      end

      response '422', 'invalid request' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { contacts.first.id }
        let(:contact) { { name: '' } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '404', 'contact not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 'invalid' }
        let(:contact) { { name: 'Jane Doe' } }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { contacts.first.id }
        let(:contact) { { name: 'Jane Doe' } }
        run_test!
      end
    end

    delete 'Deletes a contact' do
      tags 'Contacts'
      security [bearer_auth: []]
      parameter name: :id, in: :path, type: :string

      response '204', 'contact deleted' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { contacts.first.id }
        run_test!
      end

      response '404', 'contact not found' do
        let(:Authorization) { "Bearer #{token}" }
        let(:id) { 'invalid' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid_token' }
        let(:id) { contacts.first.id }
        run_test!
      end
    end
  end
end