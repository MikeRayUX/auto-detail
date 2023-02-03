class Webhooks::Stripe::SubscriptionRenewFailure
	# MUST RESTART APP FOR CHANGES TO EFFECT (BECAUSE HOOK IS INITIALIZED ON APP START) (docker-compose restart app)
	def call(event)
		# sleep 3.seconds
		log_block = '$' * 5000
		
		invoice = event.data.object
		p log_block
		p "INVOICE.PAYMENT_FAILED ATTEMPTS MADE: #{invoice.attempt_count}"
		# p invoice
		
		if invoice.subscription
			@user = User.find_by(stripe_subscription_id: invoice.subscription)
			 
			if @user
				if invoice.next_payment_attempt.present?
					@user.send_subscription_payment_failed_email!
					# @user.cancel_subscription!
				else
					@user.send_subscription_payment_dead_email!
					@user.cancel_subscription!
					@user.send_subscription_cancel_email!
				end
			end
		end

	rescue Stripe::StripeError => e
		p e
	end
end