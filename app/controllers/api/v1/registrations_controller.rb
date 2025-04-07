module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_user!, only: [:create]
      skip_before_action :set_current_organization, only: [:create]

      def create
        # Debug params
        Rails.logger.debug "Registration params: #{params.inspect}"
        
        user = User.new(user_params)
        Rails.logger.debug "User valid? #{user.valid?}"
        Rails.logger.debug "User errors: #{user.errors.full_messages}" if user.invalid?

        if user.save
          Rails.logger.debug "User saved successfully: #{user.id}"
          handle_successful_registration(user)
        else
          Rails.logger.debug "User save failed: #{user.errors.full_messages}"
          handle_failed_registration(user)
        end
      end

      private

      def handle_successful_registration(user)
        if user.active_for_authentication?
          # Sign in the user which will trigger JWT generation via devise-jwt
          sign_in(user)
          
          # Set the JWT token in the response header
          response.headers['Authorization'] = "Bearer #{request.env['warden-jwt_auth.token']}"

          render json: RegistrationSerializer.render_success(user), status: :ok
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
