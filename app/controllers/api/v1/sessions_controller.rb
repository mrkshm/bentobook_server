module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_user!, only: [:create]
      before_action :ensure_params_exist, only: [:create]

      def create
        user = User.find_by(email: user_params[:email])
        if user&.valid_password?(user_params[:password])
          # Store request info for JWT claims
          user.current_sign_in_ip = request.remote_ip

          # Sign in will trigger JWT generation via devise-jwt
          sign_in(user)

          # Get the latest token for this user
          token = user.allowlisted_jwts.order(created_at: :desc).first

          # Set the JWT token in the response header
          response.headers['Authorization'] = "Bearer #{request.env['warden-jwt_auth.token']}"

          render json: UserSerializer.render_success(user, meta: {
            token: token,
            device_info: {
              client_info: request.remote_ip,
              user_agent: request.user_agent
            }
          })
        else
          render json: UserSerializer.render_error("Invalid credentials", :unauthorized)
        end
      end

      def destroy
        # Revoke the current token
        if current_user && current_token
          current_user.revoke_session!(current_token.jti)
          sign_out current_user
        end
        render json: { message: "Signed out successfully" }
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end

      def ensure_params_exist
        return if params[:user].present?
        render json: UserSerializer.render_error("Missing user parameter", :unprocessable_entity)
      end

      def current_token
        return unless request.headers["Authorization"]
        token = request.headers["Authorization"].split(" ").last
        JWT.decode(
          token,
          Rails.application.credentials.devise_jwt_secret_key!,
          true,
          { algorithm: "HS256" }
        ).first
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
