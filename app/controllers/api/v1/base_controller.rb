module Api
  module V1
    class BaseController < ApiController
      include Pagy::Backend
      before_action :authenticate_user!
      before_action :set_default_format
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_response

      protected

      def authenticate_user!
        authenticate_jwt_user!
      end

      def set_default_format
        request.format = :json unless params[:format]
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

      def current_user
        @current_user ||= warden.authenticate(scope: :user)
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
    end
  end
end
