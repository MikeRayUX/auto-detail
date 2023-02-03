# frozen_string_literal: true
# require 'factory_bot'

if Rails.env.production?
	Rails.configuration.stripe = {
		publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
		secret_key: ENV['STRIPE_SECRET_KEY']
	}
	
	Stripe.api_key = Rails.application.credentials.stripe[:live_secret_key]
	STRIPE_PUBLIC_KEY = Rails.application.credentials.stripe[:live_publishable_key]

	StripeEvent.signing_secret = Rails.application.credentials.stripe[:live_webhook_signing_secret]
else
	Rails.configuration.stripe = {
		publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
		secret_key: ENV['STRIPE_SECRET_KEY']
	}

	Stripe.api_key = Rails.application.credentials.stripe[:test_secret_key]
	STRIPE_PUBLIC_KEY = Rails.application.credentials.stripe[:test_publishable_key]

	StripeEvent.signing_secret = Rails.application.credentials.stripe[:test_webhook_signing_secret]
end

StripeEvent.configure do |events|
	events.subscribe 'invoice.payment_succeeded', Webhooks::Stripe::SubscriptionRenewSuccess.new
	events.subscribe 'invoice.payment_failed', Webhooks::Stripe::SubscriptionRenewFailure.new
end