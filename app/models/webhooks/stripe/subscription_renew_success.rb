class Webhooks::Stripe::SubscriptionRenewSuccess
	# MUST RESTART APP FOR CHANGES TO EFFECT (BECAUSE HOOK IS INITIALIZED ON APP START) (docker-compose restart app)
	def call(event)
		# sleep 1.seconds
		log_block = '$' * 10000
		
		invoice = event.data.object
		if invoice.subscription
			@user = User.find_by(stripe_subscription_id: invoice.subscription)
			
			if @user
				@stripe_subscription = Stripe::Subscription.retrieve(@user.stripe_subscription_id)

				p log_block
				p "SUBSCRIPTION OBJECT"
				p "period start: #{Time.at(@stripe_subscription.current_period_start).to_datetime.strftime('%m/%d/%Y at %I:%M%P')}"
				p "period end: #{Time.at(@stripe_subscription.current_period_end).to_datetime.strftime('%m/%d/%Y at %I:%M%P')}"

				@user.extend_subscription!(
					@stripe_subscription.current_period_start,
					@stripe_subscription.current_period_end
				)

				@user.send_subscription_email!
			end
		end
	end
end