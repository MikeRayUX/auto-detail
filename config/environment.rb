# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

if Rails.env.production?
	# Settings for sendgrid LIVE
	ActionMailer::Base.smtp_settings = {
		user_name: 'apikey',
		password: SENDGRID_API_KEY,
		domain: SENDGRID_DOMAIN,
		address: SENDGRID_ADDRESS,
		port: 587,
		authentication: :plain,
		enable_starttls_auto: true
	}
else
	# Settings for mailcatcher TEST
	ActionMailer::Base.smtp_settings = {
	address: "mailcatcher",
	port: 1025
	}
end