class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!

  private

  def authenticate_user_from_token!
    header = request.headers['Authorization']
    return render json: { error: 'No token provided' }, status: :unauthorized unless header

    token = header.split(' ').last
    begin
      decoded = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, { algorithm: 'HS256' })
      @current_user = User.find(decoded[0]['sub'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end

