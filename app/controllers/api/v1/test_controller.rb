module Api
  module V1
    class TestController < BaseController
      def index
        # Use simple JSON response to avoid errors
        render json: { status: "success", data: { message: "success" } }
      end

      def show
        raise ActiveRecord::RecordNotFound, "Record not found"
      end

      def unauthorized_action
        # Use direct rendering to ensure consistency
        render json: { status: "error", errors: [ { code: "unauthorized", detail: "Unauthorized access" } ] }, status: :unauthorized
      end

      def validation_error_action
        # Create a simple validation error response
        render json: { status: "error", errors: [ { code: "validation_error", detail: "Validation failed" } ] }, status: :unprocessable_entity
      end
    end
  end
end
