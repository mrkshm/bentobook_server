module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_user!, only: [:create]

      def create
        user = User.new(user_params)

        if user.save
          handle_successful_registration(user)
        else
          handle_failed_registration(user)
        end
      end

      private

      def handle_successful_registration(user)
        if user.active_for_authentication?
          # Sign in the user which will trigger JWT generation via devise-jwt
          sign_in(user)
          
          # Get the latest token
          token = user.allowlisted_jwts.order(created_at: :desc).first

          render json: RegistrationSerializer.render_success(user, token), status: :ok
        else
          render json: RegistrationSerializer.render_inactive_error, status: :unauthorized
        end
      end

      def handle_failed_registration(user)
        render json: RegistrationSerializer.render_error(user.errors),
               status: :unprocessable_entity
      end

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
