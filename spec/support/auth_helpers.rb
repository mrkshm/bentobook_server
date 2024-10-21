module AuthHelpers
  def generate_jwt_token_for(user)
    JWT.encode(
      { sub: user.id, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.devise_jwt_secret_key!
    )
  end
  def authenticate_request!
    header 'Authorization', "Bearer #{@token}"
  end
end