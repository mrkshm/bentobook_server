module Api
  module V1
    class BaseController < ApiController
      include Pagy::Backend
      before_action :authenticate_user!
      before_action :set_default_format
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

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

      def set_default_format
        request.format = :json unless params[:format]
      end

      def not_found_response(exception)
        render json: {
          status: {
            code: 404,
            message: "Not Found"
          },
          errors: [ {
            code: "not_found",
            detail: exception.message
          } ]
        }, status: :not_found
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

      def render_success(resource, meta: {}, **options)
        render json: BaseSerializer.render_success(resource, meta: meta, **options)
      end

      def render_collection(resources, meta: {}, pagy: nil, **options)
        render json: BaseSerializer.render_collection(resources, meta: meta, pagy: pagy, **options)
      end

      def render_error(message, status = :unprocessable_entity, pointer = nil)
        render json: BaseSerializer.render_error(message, status, pointer), status: status
      end

      def render_validation_errors(resource)
        render json: BaseSerializer.render_validation_errors(resource), status: :unprocessable_entity
      end

      def not_found_response(exception)
        render json: BaseSerializer.render_error(
          exception.message,
          :not_found,
          "/data"
        ), status: :not_found
      end

      def unauthorized_response
        render json: BaseSerializer.render_error(
          "Unauthorized access",
          :unauthorized,
          "/data"
        ), status: :unauthorized
      end
    end
  end
end
