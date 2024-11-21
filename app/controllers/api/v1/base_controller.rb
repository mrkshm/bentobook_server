module Api
  module V1
    class BaseController < ApiController
      before_action :authenticate_user!
      
      protected

      def authenticate_user!
        if request.headers['Authorization'].present?
          token = request.headers['Authorization'].split(' ').last
          begin
            decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
            @current_user = User.find(decoded_token.first['sub'])
          rescue JWT::DecodeError => e
            render json: { error: 'Invalid token' }, status: :unauthorized
          rescue ActiveRecord::RecordNotFound
            render json: { error: 'User not found' }, status: :unauthorized
          end
        else
          render json: { error: 'Token missing' }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
