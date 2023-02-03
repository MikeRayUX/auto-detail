# frozen_string_literal: true

class JsonWebToken
  API_KEY_BASE = Rails.application.credentials.api[:secret_key_base]

  def self.encode(payload)
    jti = SecureRandom.base64
    iat = Time.now.to_i
    # 30 days
    expiration = 43_200.minutes.from_now.to_i
    # expiration = 0.seconds.from_now.to_i
    JWT.encode(payload.merge(exp: expiration, jti: jti, iat: iat), API_KEY_BASE, 'HS256')
  end

  def self.decode(token)
    # default decode
    # JWT.decode(token, API_KEY_BASE)
    JWT.decode(
      token, 
      API_KEY_BASE, 
      true, 
      { verify_jti: proc { |jti| JwtBlacklist.find_by(jti: jti).blank? }, 
      algorithm: 'HS256' })
  end

end
