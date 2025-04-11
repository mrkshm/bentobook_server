module ApiControllerAuthHelper
  def auth_headers_for(user)
    # Generate payload values
    jti = SecureRandom.uuid
    exp_time = 1.day.from_now.to_i
    iat_time = Time.current.to_i
    
    # Create an allowlisted JWT for the user - using a proper datetime for the exp field
    jwt = user.allowlisted_jwts.create!(
      jti: jti,
      exp: 1.day.from_now, # actual timestamp, not an integer
      aud: "test"
    )
    
    # Full payload for the JWT token
    payload = {
      "sub" => user.id,
      "jti" => jti,
      "exp" => exp_time,   # integer for JWT
      "iat" => iat_time,
      "aud" => "test",
      "client_info" => "127.0.0.1" # simulate IP
    }

    token = JWT.encode(
      payload,
      Rails.application.credentials.devise_jwt_secret_key,
      'HS256'
    )

    # Add token to request headers
    request.headers['Authorization'] = "Bearer #{token}"
    # Standard headers for JSON API
    request.headers['Accept'] = 'application/json'
    request.headers['Content-Type'] = 'application/json'
  end
end

RSpec.configure do |config|
  config.include ApiControllerAuthHelper, type: :controller
end