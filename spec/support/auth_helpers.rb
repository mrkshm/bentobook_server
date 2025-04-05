module AuthHelpers
  def authenticate_request!
    header 'Authorization', "Bearer #{@token}"
  end

  def sign_in_with_token(user, _user_session = nil)
    # Sign in with Devise first
    sign_in(user)

    # Create a JWT token using Devise JWT's encoder
    scope = :user
    aud = scope.to_s
    
    # Create the token using Devise JWT's encoder
    token = Warden::JWTAuth::UserEncoder.new.call(
      user,
      scope,
      aud
    ).first

    # Create an allowlisted JWT record
    jti = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key, true, { algorithm: 'HS256' })[0]['jti']
    user.allowlisted_jwts.create!(
      jti: jti,
      aud: aud,
      exp: 1.day.from_now
    )

    # Return headers hash
    {
      'Authorization' => "Bearer #{token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request
end
