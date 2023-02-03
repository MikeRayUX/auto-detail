def generate_auth_token(user_id)
  JsonWebToken.encode(sub: user_id, exp: 1_440.minutes.from_now.to_i)
end