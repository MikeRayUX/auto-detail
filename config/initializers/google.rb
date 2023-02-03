GOOGLE_API_KEY = Rails.application.credentials.google[:key]
RECAPTCHA_V2_PUBLIC_KEY = Rails.application.credentials.google[:recaptcha_v2_public_site_key]

if Rails.env.test?
  RECAPTCHA_V2_SECRET_KEY = '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWelse'
else
  RECAPTCHA_V2_SECRET_KEY = Rails.application.credentials.google[:recaptcha_v2_secret_key]
end