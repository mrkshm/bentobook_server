module Api
  module V1
    class TestController < BaseController
      def index
        render_success({ message: "success" })
      end

      def show
        raise ActiveRecord::RecordNotFound, "Record not found"
      end

      def unauthorized
        unauthorized_response
      end

      def validation_error
        resource = Restaurant.new
        resource.valid? # trigger validation errors
        render_validation_errors(resource)
      end
    end
  end
end
