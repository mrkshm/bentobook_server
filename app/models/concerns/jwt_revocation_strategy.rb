module JwtRevocationStrategy
  extend ActiveSupport::Concern

  included do
    def self.jwt_revoked?(payload, user)
      # Check if session exists and is inactive (revoked)
      user.user_sessions.exists?(jti: payload["jti"], active: false)
    end

    def self.revoke_jwt(payload, user)
      # Find and revoke the specific session
      session = user.user_sessions.find_by(jti: payload["jti"])
      session&.update!(active: false)
    end
  end

  def jwt_revoked?(payload, user)
    self.class.jwt_revoked?(payload, user)
  end

  def revoke_jwt(payload, user)
    self.class.revoke_jwt(payload, user)
  end

  def generate_jwt_token(session)
    payload = {
      "jti" => session.jti,
      "sub" => id,
      "client_id" => session.client_name,
      "iat" => Time.current.to_i,
      "exp" => 1.hour.from_now.to_i
    }

    JWT.encode(
      payload,
      Rails.application.credentials.devise_jwt_secret_key!,
      "HS256"
    )
  end
end
