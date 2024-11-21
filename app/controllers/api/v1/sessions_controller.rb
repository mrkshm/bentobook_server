module Api
  module V1
    class SessionsController < ApplicationController
      include ActionController::MimeResponds

      respond_to :json
      protect_from_forgery with: :null_session
      before_action :ensure_params_exist, only: [ :create ]
      skip_before_action :verify_authenticity_token

      def create
        @resource = User.find_for_database_authentication(email: params[:user][:email])
        if @resource && @resource.valid_password?(params[:user][:password])
          client_info = {
            name: params.dig(:client, :name) || request.user_agent || "Unknown",
            platform: params.dig(:client, :platform) || "web"
          }

          session = UserSession.create_session(@resource, client_info)

          render json: {
            status: {
              code: 200,
              message: "Logged in successfully."
            },
            data: UserSerializer.new(@resource).as_json,
            token: generate_jwt_token(@resource, session)
          }, status: :ok
        else
          render json: {
            status: {
              code: 401,
              message: "Invalid email or password."
            }
          }, status: :unauthorized
        end
      end

      def refresh
        token = request.headers["Authorization"]&.split(" ")&.last
        return unauthorized_response unless token

        begin
          Rails.logger.debug "Received token: #{token}"
          decoded_token = JWT.decode(
            token,
            Rails.application.credentials.devise_jwt_secret_key,
            true,
            { algorithm: "HS256" }
          ).first
          Rails.logger.debug "Decoded token: #{decoded_token.inspect}"

          # Validate token and session
          unless UserSession.validate_token(decoded_token)
            return unauthorized_response
          end

          # Generate new token
          user = User.find(decoded_token["sub"])
          session = user.user_sessions.find_by!(jti: decoded_token["jti"])
          Rails.logger.debug "Found session: #{session.inspect}"

          render json: {
            token: generate_jwt_token(user, session)
          }, status: :ok
        rescue JWT::ExpiredSignature
          # Allow refresh of expired tokens
          begin
            decoded_token = JWT.decode(
              token,
              Rails.application.credentials.devise_jwt_secret_key,
              false, # Skip verification for expired tokens
              { algorithm: "HS256" }
            ).first
            Rails.logger.debug "Decoded token: #{decoded_token.inspect}"

            # Validate session even for expired tokens
            unless UserSession.validate_token(decoded_token)
              return unauthorized_response
            end

            # Generate new token
            user = User.find(decoded_token["sub"])
            session = user.user_sessions.find_by!(jti: decoded_token["jti"])
            Rails.logger.debug "Found session: #{session.inspect}"

            render json: {
              token: generate_jwt_token(user, session)
            }, status: :ok
          rescue StandardError => e
            Rails.logger.error "Unexpected error: #{e.class} - #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
            unauthorized_response
          end
        rescue StandardError => e
          Rails.logger.error "Unexpected error: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          unauthorized_response
        end
      end

      def destroy
        Rails.logger.debug "Headers: #{request.headers.to_h.select { |k, v| k.start_with?('HTTP_') }}"
        return no_session_response unless request.headers["Authorization"].present?

        token = request.headers["Authorization"].split(" ").last
        Rails.logger.debug "Received token: #{token}"

        begin
          Rails.logger.debug "Decoding token with key: #{Rails.application.credentials.devise_jwt_secret_key.present? ? 'present' : 'missing'}"
          decoded_token = JWT.decode(
            token,
            Rails.application.credentials.devise_jwt_secret_key,
            true,
            { algorithm: "HS256" }
          ).first
          Rails.logger.debug "Decoded token: #{decoded_token.inspect}"

          session = UserSession.find_by(jti: decoded_token["jti"])
          Rails.logger.debug "Found session: #{session.inspect}"
          return no_session_response unless session&.active?

          session.revoke!
          Rails.logger.debug "Session revoked"

          render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
        rescue JWT::DecodeError => e
          Rails.logger.error "JWT decode error: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          no_session_response
        rescue => e
          Rails.logger.error "Unexpected error: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          raise
        end
      end

      private

      def ensure_params_exist
        return if params[:user].present? && params[:user][:email].present? && params[:user][:password].present?
        render json: {
          status: {
            code: 400,
            message: "Missing required parameters."
          }
        }, status: :bad_request
      end

      def unauthorized_response
        Rails.logger.debug "Returning unauthorized response"
        render json: {
          status: 401,
          message: "Unauthorized."
        }, status: :unauthorized
      end

      def no_session_response
        Rails.logger.debug "Returning no session response"
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end

      def generate_jwt_token(user, session)
        payload = {
          sub: user.id,
          jti: session.jti,
          exp: 24.hours.from_now.to_i,
          client: {
            name: session.client_name
          }
        }

        Rails.logger.debug "Generating JWT token with payload: #{payload.inspect}"
        JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key, "HS256")
      end
    end
  end
end
