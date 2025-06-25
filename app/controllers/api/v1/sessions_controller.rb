module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_user!, only: [ :create, :refresh ], raise: false
      skip_before_action :set_current_organization, only: [ :create, :refresh ]
      before_action :ensure_params_exist, only: [ :create ]

      # POST /api/v1/auth/login
      def create
        user = User.find_by(email: user_params[:email])

        # Check if user exists and password is valid
        if user.nil? || !user.valid_password?(user_params[:password].to_s)
          render json: UserSerializer.render_error("Invalid credentials", :unauthorized), status: :unauthorized
          return
        end

        # User is valid, proceed with authentication
        # Store request info for JWT claims
        user.current_sign_in_ip = request.remote_ip

        # Sign in will trigger JWT generation via devise-jwt
        sign_in(user)

        # Get the token from the request environment
        token = request.env["warden-jwt_auth.token"]
        response.headers["Authorization"] = "Bearer #{token}"

        # Decode the token to get jti and expiration
        begin
          payload = JWT.decode(
            token,
            Rails.application.credentials.devise_jwt_secret_key!,
            true,
            { algorithm: "HS256" }
          ).first

          # Set organization context - Make sure we don't try to access profile
          organization = user.organizations.first

          render json: UserSerializer.render_success(user, meta: {
            token_info: {
              jti: payload["jti"],
              exp: Time.at(payload["exp"]).utc.iso8601
            },
            device_info: {
              client_info: request.remote_ip,
              user_agent: request.user_agent
            },
            organization: { id: organization.id }
          })
        rescue JWT::DecodeError
          render json: UserSerializer.render_error("Error processing token", :internal_server_error)
        end
      end

      # DELETE /api/v1/auth/session/current
      def destroy
        # Revoke the current token
        if current_user && current_jwt_payload
          begin
            jti = current_jwt_payload["jti"]
            current_user.revoke_jwt(jti, Devise.jwt.expiration_time.from_now)
            sign_out current_user
            render json: { message: "Signed out successfully" }
          rescue => e
            Rails.logger.error("Error in destroy: #{e.message}")
            render json: { message: "Error logging out", error: e.message }, status: :internal_server_error
          end
        else
          render json: { message: "No active session found" }, status: :ok
        end
      end

      # POST /api/v1/auth/token/refresh
      def refresh
        # Extract and validate the current token
        if request.headers["Authorization"].present?
          token = request.headers["Authorization"].split(" ").last
          begin
            payload = JWT.decode(
              token,
              Rails.application.credentials.devise_jwt_secret_key!,
              true,
              { algorithm: "HS256" }
            ).first

            # Find the user and check if token is valid
            user = User.find(payload["sub"])
            if user && user.jwt_revoked?(payload["jti"], payload["exp"])
              render json: UserSerializer.render_error("Token has been revoked", :unauthorized), status: :unauthorized
              return
            end

            # Revoke the old token
            user.revoke_jwt(payload["jti"], Time.now)

            # Sign in to generate a new token
            user.current_sign_in_ip = request.remote_ip
            sign_in(user)

            # Get the new token from the request environment
            new_token = request.env["warden-jwt_auth.token"]
            response.headers["Authorization"] = "Bearer #{new_token}"

            # Decode the new token to get jti and expiration
            new_payload = JWT.decode(
              new_token,
              Rails.application.credentials.devise_jwt_secret_key!,
              true,
              { algorithm: "HS256" }
            ).first

            # Set organization context
            organization = user.organizations.first

            render json: UserSerializer.render_success(user, meta: {
              token_info: {
                jti: new_payload["jti"],
                exp: Time.at(new_payload["exp"]).utc.iso8601
              },
              device_info: {
                client_info: request.remote_ip,
                user_agent: request.user_agent
              },
              organization: { id: organization.id }
            })
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
            Rails.logger.error("Error in refresh: #{e.message}")
            render json: UserSerializer.render_error("Invalid token", :unauthorized), status: :unauthorized
          end
        else
          render json: UserSerializer.render_error("Authorization header missing", :unauthorized), status: :unauthorized
        end
      end

      # GET /api/v1/auth/sessions
      def index
        if current_user
          sessions = current_user.allowlisted_jwts.order(created_at: :desc).map do |jwt|
            begin
              {
                id: jwt.id,
                created_at: jwt.created_at,
                expires_at: Time.at(JWT.decode(
                  jwt.token.to_s,
                  Rails.application.credentials.devise_jwt_secret_key!,
                  true,
                  { algorithm: "HS256" }
                ).first["exp"]).utc,
                current: jwt.jti == current_jwt_payload["jti"]
              }
            rescue JWT::DecodeError => e
              Rails.logger.error("Error decoding JWT: #{e.message}")
              nil
            end
          end.compact

          render json: { sessions: sessions }
        else
          render json: UserSerializer.render_error("Not authenticated", :unauthorized), status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/sessions/:id
      def destroy_session
        if current_user
          jwt = current_user.allowlisted_jwts.find_by(id: params[:id])
          if jwt
            current_user.revoke_jwt(jwt.jti, Devise.jwt.expiration_time.from_now)
            render json: { message: "Session revoked successfully" }
          else
            render json: { message: "Session not found" }, status: :not_found
          end
        else
          render json: UserSerializer.render_error("Not authenticated", :unauthorized), status: :unauthorized
        end
      end

      # DELETE /api/v1/auth/sessions/others
      def destroy_all
        if current_user && current_jwt_payload
          current_jti = current_jwt_payload["jti"]
          current_user.allowlisted_jwts.where.not(jti: current_jti).each do |jwt|
            current_user.revoke_jwt(jwt.jti, Devise.jwt.expiration_time.from_now)
          end
          render json: { message: "All other sessions revoked successfully" }
        else
          render json: UserSerializer.render_error("Not authenticated", :unauthorized), status: :unauthorized
        end
      end

      # Alias for destroy to match routes
      def destroy_current
        destroy
      end

      private

      def user_params
        params.require(:user).permit(:email, :password)
      end

      def ensure_params_exist
        return if params[:user].present?
        render json: UserSerializer.render_error("Missing user parameter", :unprocessable_entity), status: :unprocessable_entity
      end

      def current_jwt_payload
        return nil unless request.headers["Authorization"]
        token = request.headers["Authorization"].split(" ").last

        begin
          JWT.decode(
            token,
            Rails.application.credentials.devise_jwt_secret_key!,
            true,
            { algorithm: "HS256" }
          ).first
        rescue JWT::DecodeError => e
          Rails.logger.error("Error decoding JWT in current_jwt_payload: #{e.message}")
          nil
        end
      end
    end
  end
end
