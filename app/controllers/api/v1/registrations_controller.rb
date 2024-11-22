module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_user!

      def create
        user = User.new(sign_up_params)

        if user.save
          handle_successful_registration(user)
        else
          handle_failed_registration(user)
        end
      end

      private

      def handle_successful_registration(user)
        if user.active_for_authentication?
          session = create_user_session(user)
          token = generate_jwt_token(user, session)

          render json: RegistrationSerializer.render_success(user, token), status: :ok
        else
          render json: RegistrationSerializer.render_inactive_error, status: :unauthorized
        end
      end

      def handle_failed_registration(user)
        render json: RegistrationSerializer.render_error(user.errors),
               status: :unprocessable_entity
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def create_user_session(user)
        browser = Browser.new(request.user_agent)
        client_info = {
          name: params.dig(:client, :name) || request.user_agent || "Unknown",
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          device_type: browser.device.mobile? ? "mobile" : (browser.device.tablet? ? "tablet" : "desktop"),
          os_name: browser.platform.name,
          os_version: browser.platform.version,
          browser_name: browser.name,
          browser_version: browser.version
        }

        UserSession.create_session(user, client_info)
      end

      def generate_jwt_token(user, session)
        payload = {
          sub: user.id,
          jti: session.jti,
          exp: 24.hours.from_now.to_i,
          iat: Time.current.to_i
        }

        JWT.encode(
          payload,
          Rails.application.credentials.devise_jwt_secret_key,
          "HS256"
        )
      end
    end
  end
end
