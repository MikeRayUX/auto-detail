# frozen_string_literal: true

SENDGRID_USER_NAME = Rails.application.credentials.sendgrid[:user_name]
SENDGRID_API_KEY = Rails.application.credentials.sendgrid[:api_key]
SENDGRID_DOMAIN = Rails.application.credentials.sendgrid[:domain]
SENDGRID_ACCOUNT_PASSWORD = Rails.application.credentials.sendgrid[:account_password]
SENDGRID_ADDRESS = Rails.application.credentials.sendgrid[:address]

SENDGRID_MARKETING_URL = 'https://api.sendgrid.com/v3/marketing/contacts'

if Rails.env.test?
  SENDGRID_MAIL_SEND_URL = "https://api.sendgrid.com/v3/marketing/test/send_email"
else
  SENDGRID_MAIL_SEND_URL = "https://api.sendgrid.com/v3/mail/send"
end

SENDGRID_HEADERS = {
  'Authorization' => "Bearer #{SENDGRID_API_KEY}",
  'Content-Type' => 'application/json',
  'Accept' => 'application/json'
}