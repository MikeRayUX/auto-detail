require 'webhook_helper'

# # Always valid
CARD_VALID = '4242424242424242'
CARD_VALID_MASTERCARD = '5555555555554444'

# # Charge is declined with a card_declined code.
CARD_DECLINED = '4000000000000002'

# # Charge is declined with a card_declined code. The decline_code attribute is insufficient_funds.
CARD_INSUFFICIENT_FUNDS = '4000000000009995'

# Attaching this card to a Customer object succeeds, but attempts to charge the customer fail.
CARD_WILL_FAIL = '4000000000000341'

# 4_000_000_000_000_341

def new_stripe_token(card_number)
  p "#{'*' * rand(1..10)} CREATING STRIPE TOKEN FROM CARD #(#{card_number})..."
  @token = Stripe::Token.create({
    card: {
      number: card_number,
      exp_month: 2,
      exp_year: 2022,
      cvc: '314',
    },
  })


  @token

  rescue Stripe::StripeError => e
    p 'new_stripe_token'
    p e
end

def create_stripe_customer_from_token(user, token)
  p "#{'*' * rand(1..10)} CREATING STRIPE CUSTOMER FROM TOKEN..."
  @customer = Stripe::Customer.create(
    source: token,
    email: user.email
  )

  p "#{'*' * rand(1..10)} STRIPE CUSTOMER CREATED"

  @card = @customer.sources.data.first

  user.update_attributes!(
    stripe_customer_id: @customer.id,
    card_brand: @card[:brand],
    card_exp_month: @card[:exp_month],
    card_exp_year: @card[:exp_year],
    card_last4: @card[:last4]
  )
  user.reload

  rescue Stripe::StripeError => e
    p 'create_stripe_customer_from_token'
    p e
end

def retrieve_stripe_customer(user)
  p "#{'*' * rand(1..10)} RETRIEVING STRIPE CUSTOMER..."
  @customer = Stripe::Customer.retrieve(user.stripe_customer_id)
end

def update_stripe_payment_method(user, token)
  p "#{'*' * rand(1..10)} UPDATING STRIPE CUSTOMER PAYMENT METHOD FROM TOKEN..."
  Stripe::Customer.update(
    user.stripe_customer_id,
    source: token
  )
  user.update_attributes!(
    card_brand: 'visa',
    card_exp_month: '5',
    card_exp_year: '24',
    card_last4: '5555'
  )

  rescue Stripe::StripeError => e
    p 'update_stripe_payment_method'
    p e
end

def delete_stripe_payment_method(user)
  p "#{'*' * rand(1..10)} DELETING STRIPE PAYMENT METHOD..."
  @customer = Stripe::Customer.retrieve(user.stripe_customer_id)

  Stripe::Customer.delete_source(
    user.stripe_customer_id,
    @customer.sources.data.first.id
  )

  p "#{'*' * rand(1..10)} STRIPE PAYMENT METHOD DELETED"
  rescue Stripe::StripeError => e
    p 'delete_stripe_payment_method'
    p e
end

def activate_expire_soon_subscription(user, region, subscription, secs)
  p "#{'*' * rand(1..10)} CREATING STRIPE SUBSCRIPTON WITH TRIAL END (WILL EXPIRE IN #{secs} seconds)..."
  @sub = Stripe::Subscription.create({
    customer: user.stripe_customer_id,
    default_tax_rates: [user.address.region.stripe_tax_rate_id],
    items: [
      {price: subscription.stripe_price_id},
    ],
    trial_end: (DateTime.current + secs.seconds).to_i,
    # proration_behavior: 'none',
    # billing_cycle_anchor: 'now'
  })

  user.update(
    stripe_subscription_id: @sub.id, 
    subscription_activated_at: Time.at(@sub.current_period_start),
    subscription_expires_at: Time.at(@sub.current_period_end)
  )

  user.transactions.create!(
    stripe_customer_id: user.stripe_customer_id,
    stripe_subscription_id: @sub.id,
    stripe_charge_id: @sub.id,
    paid: 'paid',
    card_brand: user.card_brand,
    card_exp_month: user.card_exp_month,
    card_exp_year: user.card_exp_year,
    card_last4: user.card_last4,
    customer_email: user.email,
    subtotal: subscription.price,
    tax: subscription.tax(region.tax_rate),
    tax_rate: region.tax_rate,
    grandtotal: subscription.grandtotal(region.tax_rate),
    region_name: region.area
  )

  rescue Stripe::StripeError => e
    p 'activate_expire_soon_subscription'
    p e
end

def make_stripe_subscription_trial_end_soon(user, secs)
  p "#{'*' * rand(1..10)} UPDATING STRIPE SUBSCRIPTION TO TRIAL END SOON (#{secs} SECONDS)..."
  Stripe::Subscription.update(user.stripe_subscription_id, {
    trial_end: (DateTime.current + secs.seconds).to_i,
    # prorate: false,
    proration_behavior: 'none',
    # billing_cycle_anchor: 'now'
  })

  p "#{'*' * rand(1..10)} TRIAL END UPDATED SUCCESSFULLY"
 
  rescue Stripe::StripeError => e
    p 'make_stripe_subscription_trial_end_soon'
    p e
end

def wait_for_trial_expire(secs)
  # wait for billing period to end (invoice is created)
  p "#{'*' * rand(1..10)} WAITING #{secs} SECONDS FOR TRIAL TO EXPIRE....."
  sleep_with_feedback(secs)
  p "#{'*' * rand(1..10)} TRIAL SHOULD HAVE EXPIRED, CUSTOMER SUBSCRIPTON SHOULD BE UPDATED ON STRIPE END"

  p "#{'*' * rand(1..10)} GIVING STRIPE #{secs} SECONDS TO CREATE THE BILLABLE INVOICE....."
  sleep_with_feedback(secs)
  p "#{'*' * rand(1..10)} PROCESS WAIT ENDED - INVOICE SHOULD NOW BE BILLABLE"
end 

def last_stripe_subscription_invoice(stripe_subscription_id)
  Stripe::Subscription.retrieve(stripe_subscription_id).latest_invoice
end

def pay_stripe_invoice(invoice)
  p "#{'*' * rand(1..10)} BILLING STRIPE INVOICE...."
  
  Stripe::Invoice.pay(invoice)
  
  p "#{'*' * rand(1..10)} INVOICE BILLED COMPLETED"
  rescue Stripe::StripeError => e
    p 'bill_stripe_subscription_now'
    p e
end

def cancel_stripe_subscription(user)
  @sub = Stripe::Subscription.retrieve(user.stripe_subscription_id)

  # p @sub

  @deleted = Stripe::Subscription.delete(user.stripe_subscription_id)

  p @deleted
  # p @cancelled
end



