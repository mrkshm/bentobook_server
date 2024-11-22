module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_user!, only: [ :create ]
      before_action :ensure_params_exist, only: [ :create ]

      def create
        user = User.find_by(email: user_params[:email])
        if user&.valid_password?(user_params[:password])
          session = create_user_session(user)
          token = generate_jwt_token(user, session)

          render json: {
            status: { code: 200, message: "Logged in successfully." },
            data: {
              token: token,
              user: user.as_json(only: [ :id, :email ]),
              device_info: session.device_info
            }
          }
        else
          render json: {
            status: { code: 401, message: "Invalid email or password." }
          }, status: :unauthorized
        end
      end

      def index
        sessions = current_user.user_sessions.active.map do |session|
          {
            id: session.id,
            client_name: session.client_name,
            device_info: session.device_info,
            last_used_at: session.last_used_at,
            current: session.jti == current_session.jti,
            suspicious: session.suspicious
          }
        end

        render json: { sessions: sessions }
      end

      def destroy
        session = current_user.user_sessions.active.find_by(id: params[:id])

        unless session
          return render json: {
            status: "error",
            errors: [ {
              code: "session_not_found",
              detail: "Session not found"
            } ],
            meta: {
              timestamp: Time.current.iso8601
            }
          }, status: :not_found
        end

        if session.jti == current_session.jti
          return render json: {
            status: "error",
            errors: [ {
              code: "invalid_request",
              detail: "Cannot revoke current session"
            } ],
            meta: {
              timestamp: Time.current.iso8601
            }
          }, status: :bad_request
        end

        session.revoke!
        render json: {
          status: "success",
          meta: {
            message: "Session revoked successfully.",
            timestamp: Time.current.iso8601
          }
        }
      end

      def destroy_all
        current_user.user_sessions.active
          .where.not(jti: current_session.jti)
          .update_all(active: false)

        render json: {
          status: "success",
          meta: {
            message: "All other sessions revoked successfully.",
            timestamp: Time.current.iso8601
          }
        }
      end

      def destroy_current
        begin
          current_session.revoke!
          render json: {
            status: "success",
            meta: {
              message: "Logged out successfully.",
              timestamp: Time.current.iso8601
            }
          }
        rescue => e
          Rails.logger.error "Error in destroy_current: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: {
            status: "error",
            errors: [ {
              code: "logout_failed",
              detail: "Failed to logout"
            } ],
            meta: {
              timestamp: Time.current.iso8601
            }
          }, status: :internal_server_error
        end
      end

      def refresh
        unless current_session&.active?
          return render json: {
            status: "error",
            errors: [ {
              code: "invalid_session",
              detail: "Invalid or expired session"
            } ],
            meta: {
              timestamp: Time.current.iso8601
            }
          }, status: :unauthorized
        end

        begin
          Rails.logger.info "Refreshing token for session #{current_session.id}"
          current_session.touch(:last_used_at)
          token = generate_jwt_token(current_user, current_session)
          Rails.logger.info "Generated new token"
          current_session.token = token
          Rails.logger.info "Set token on session"

          render json: SessionSerializer.render_success(current_session)
        rescue => e
          Rails.logger.error "Error in refresh: #{e.class} - #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: {
            status: "error",
            errors: [ {
              code: "refresh_failed",
              detail: "Failed to refresh token"
            } ],
            meta: {
              timestamp: Time.current.iso8601
            }
          }, status: :internal_server_error
        end
      end

      private

      def ensure_params_exist
        return if params[:user].present? &&
                 params[:user][:email].present? &&
                 params[:user][:password].present?

        render json: {
          status: "error",
          errors: [ {
            code: "invalid_request",
            detail: "Missing required parameters"
          } ],
          meta: {
            timestamp: Time.current.iso8601
          }
        }, status: :bad_request
      end

      def user_params
        params.require(:user).permit(:email, :password)
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
          Rails.application.credentials.devise_jwt_secret_key!,
          "HS256"
        )
      end
    end
  end
end
