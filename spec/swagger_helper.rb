# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

def generate_jwt_token(user)
  payload = {
    sub: user.id,
    jti: user.jti,
    scp: 'user',
    exp: 24.hours.from_now.to_i
  }
  JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key!)
end

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearer_format: 'JWT'
          }
        }
      },
      security: [
        { bearer_auth: [] }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'
  config.openapi_format = :yaml

  # Conditional Setup for Authenticated Requests
  config.before(:each, type: :request) do
    @user = create(:user)
    @token = generate_jwt_token(@user)
  end
end
