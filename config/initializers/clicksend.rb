# frozen_string_literal: true
CLICKSEND_USERNAME = Rails.application.credentials.clicksend[:username]
CLICKSEND_PASSWORD = Rails.application.credentials.clicksend[:password]

ClickSendClient.configure do |config|
  config.username = CLICKSEND_USERNAME
  config.password = CLICKSEND_PASSWORD
end