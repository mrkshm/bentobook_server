module AuthHelpers
  def authenticate_request!
    header 'Authorization', "Bearer #{@token}"
  end

  def sign_in_with_token(user, user_session)
    token = generate_jwt_token(user, user_session)

    @jwt_payload = JWT.decode(
      token,
      Rails.application.credentials.devise_jwt_secret_key,
      true,
      { algorithm: 'HS256' }
    ).first

    @headers ||= {}
    @headers['Authorization'] = "Bearer #{token}"
  end

  def generate_jwt_token(user, user_session)

    payload = {
      "sub" => user.id,
      "jti" => user_session.jti,
      "client_id" => user_session.client_name,
      "exp" => 24.hours.from_now.to_i,
      "iat" => Time.current.to_i
    }

    token = JWT.encode(
      payload,
      Rails.application.credentials.devise_jwt_secret_key,
      'HS256'
    )
    token
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
