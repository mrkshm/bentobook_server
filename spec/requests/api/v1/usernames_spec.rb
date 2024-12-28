require 'swagger_helper'

RSpec.describe 'Api::V1::Usernames', type: :request do
  let(:user) { create(:user) }
  let(:user_session) do
    create(:user_session,
           user: user,
           active: true,
           client_name: 'web',
           ip_address: '127.0.0.1')
  end
  let(:Authorization) { "Bearer #{user_session.token}" }

  before do
    @headers = {}
    sign_in_with_token(user, user_session)
  end

  path '/api/v1/usernames/verify' do
    post 'Verifies username availability' do
      tags 'Usernames'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string }
        },
        required: ['username']
      }
      
      response '200', 'username availability checked' do
        let(:params) { { username: 'testuser' } }
        
        schema type: :object,
          properties: {
            status: { type: :string, enum: ['success'] },
            data: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string },
                attributes: {
                  type: :object,
                  properties: {
                    available: { type: :boolean },
                    username: { type: :string }
                  },
                  required: ['available', 'username']
                }
              },
              required: ['id', 'type', 'attributes']
            },
            meta: {
              type: :object,
              properties: {
                timestamp: { type: :string, format: 'date-time' },
                message: { type: :string }
              },
              required: ['timestamp', 'message']
            }
          }

        context 'when username does not exist' do
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data']['attributes']['available']).to be true
            expect(data['meta']['message']).to eq 'Username is available'
          end
        end

        context 'when username exists' do
          before do
            create(:profile, username: 'testuser')
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data']['attributes']['available']).to be false
            expect(data['meta']['message']).to eq 'Username is taken'
          end
        end
      end

      response '400', 'invalid request' do
        let(:params) { { username: '' } }
        
        schema type: :object,
          properties: {
            status: { type: :string, enum: ['error'] },
            errors: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  code: { type: :string },
                  detail: { type: :string }
                },
                required: ['code', 'detail']
              }
            },
            meta: {
              type: :object,
              properties: {
                timestamp: { type: :string, format: 'date-time' }
              },
              required: ['timestamp']
            }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors'].first['detail']).to eq 'Username parameter is required'
        end
      end
    end
  end
end