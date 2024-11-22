module Api
  module V1
    class BaseController < ApiController
      include Pagy::Backend
      before_action :authenticate_user!

      protected

      def authenticate_user!
        header = request.headers["Authorization"]
        token = header.to_s.split(" ").last
        return unauthorized_response unless token

        begin
          @jwt_payload = JWT.decode(
            token,
            Rails.application.credentials.devise_jwt_secret_key,
            true,
            { algorithm: "HS256" }
          ).first

          @current_user = User.find(@jwt_payload["sub"])
          @current_session = UserSession.find_by(jti: @jwt_payload["jti"])

          unless @current_user && @current_session&.active?
            return unauthorized_response
          end

          # Update last used timestamp
          @current_session.touch_last_used!
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
          render_error("Invalid token or authentication credentials", :unauthorized)
        end
      end

      def unauthorized_response
        render json: {
          status: {
            code: 401,
            message: "Unauthorized"
          },
          errors: [ {
            code: "unauthorized",
            detail: "You need to sign in or sign up before continuing."
          } ]
        }, status: :unauthorized
      end

      def current_user
        @current_user
      end

      def current_session
        @current_session
      end

      def render_error(message, code = :unprocessable_entity)
        render json: {
          status: {
            code: Rack::Utils::SYMBOL_TO_STATUS_CODE[code],
            message: message
          },
          errors: [ {
            code: "general_error",
            detail: message
          } ]
        }, status: code
      end
    end
  end
end
