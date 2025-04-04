module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      skip_before_action :authenticate_user!, only: [ :create, :update ]
      respond_to :json

      # POST /api/v1/auth/password/reset
      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)
        if successfully_sent?(resource)
          render json: { message: "Reset password instructions have been sent to your email." }
        else
          render json: {
            error: "Failed to send reset password instructions",
            details: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/password/reset/:token
      def update
        self.resource = resource_class.reset_password_by_token(resource_params)
        if resource.errors.empty?
          # Sign in the user after password reset
          sign_in(resource_name, resource)

          # Get the latest token
          token = resource.allowlisted_jwts.order(created_at: :desc).first

          render json: {
            message: "Password has been reset successfully.",
            token: token
          }
        else
          render json: {
            error: "Failed to reset password",
            details: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
      end
    end
  end
end
