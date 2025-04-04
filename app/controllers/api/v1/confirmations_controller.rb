module Api
  module V1
    class ConfirmationsController < Devise::ConfirmationsController
      skip_before_action :authenticate_user!, only: [:create, :show]
      respond_to :json

      # POST /api/v1/auth/email/verify
      def create
        self.resource = resource_class.send_confirmation_instructions(resource_params)
        if successfully_sent?(resource)
          render json: { message: "Confirmation instructions have been sent to your email." }
        else
          render json: { 
            error: "Failed to send confirmation instructions",
            details: resource.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/auth/email/verify/:token
      def show
        self.resource = resource_class.confirm_by_token(params[:token])
        if resource.errors.empty?
          # Sign in the user after confirmation if they're not signed in
          sign_in(resource) unless user_signed_in?
          
          # Get the latest token if we signed them in
          token = resource.allowlisted_jwts.order(created_at: :desc).first if user_signed_in?

          render json: {
            message: "Email confirmed successfully.",
            token: token
          }
        else
          render json: { 
            error: "Failed to confirm email",
            details: resource.errors.full_messages 
          }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:user).permit(:email)
      end
    end
  end
end
