module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json
      skip_before_action :verify_authenticity_token
      before_action :ensure_params_exist, only: [:create]
      before_action :authenticate_user!, only: [:destroy]

      def create
        self.resource = User.find_for_database_authentication(email: params[:user][:email])
        if self.resource && self.resource.valid_password?(params[:user][:password])
          sign_in(resource_name, resource)
          render json: {
            status: { code: 200, message: 'Logged in successfully.' },
            data: UserSerializer.new(resource).serialize,
            token: current_token
          }, status: :ok
        else
          render json: {
            status: 401,
            message: 'Invalid email or password.'
          }, status: :unauthorized
        end
      end

      def destroy
        token = request.headers['Authorization']&.split(' ')&.last

        if token
          begin
            decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
            
            # Manually find the user based on the JWT payload
            user_id = decoded_token.first['sub']
            user = User.find_by(id: user_id)

            if user
              sign_out(user)
              render json: {
                status: 200,
                message: 'Logged out successfully.'
              }, status: :ok
            else
              render json: {
                status: 401,
                message: "Couldn't find an active session."
              }, status: :unauthorized
            end
          rescue JWT::DecodeError => e
            render json: {
              status: 401,
              message: "Invalid token."
            }, status: :unauthorized
          end
        else
          render json: {
            status: 401,
            message: "No token provided."
          }, status: :unauthorized
        end
      end

      protected

      def auth_options
        { scope: resource_name, recall: "#{controller_path}#new" }
      end

      def current_token
        request.env['warden-jwt_auth.token']
      end

      private

      def ensure_params_exist
        return if params[:user].present?

        render json: {
          status: 400,
          message: 'Missing user parameter.'
        }, status: :bad_request
      end

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: UserSerializer.new(resource).serialize,
          token: current_token
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            status: 200,
            message: 'Logged out successfully.'
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      end
    end
  end
end
