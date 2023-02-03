# 1. THE HOOK IS IN ANOTHER ENVIRONMENT (DEVELOPMENT). THE HOOK WILL NOT SEE THE USER STRIPE CUSTOMER ID OR SUBSCRIPTION ID UNLESS CHANGES IN SPEC ARE ACTUALLY SAVED TO THE DEVELOPMENT DB, AS IT IS NOT PERMANENTLY SAVED WHEN TRANSACTIONAL FIXTURES IS SET TO TRUE (SET BY DEFAULT IN RAILS_HELPER)

# 2. REQUIRES STRIPE-CLI RUNNING, AUTHORIZED, AND LISTENING IN ORDER TO FORWARD WEBHOOK REQUESTS FROM STRIPE TO APP ON LOCALHOST
# example: 
# 'stripe listen --api-key sk_test_0d4LHDkpMBhESxsqudQXGMMW --forward-to 192.168.0.12:3001/

require 'no_transactional_fixtures'
require 'webhook_helper'
require 'stripe_helper'

RSpec.describe 'webhooks/stripe/stripe_subscription_renew_failure', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    # ActionMailer::Base.deliveries.clear
    # CONNECT TO DEVELOPMENT DB
    switch_db('development')

    @region = Region.create!(attributes_for(:region))
    @subscription = Subscription.create!(attributes_for(:subscription))
    @user = User.create!(attributes_for(:user).merge(email: "Customer#{rand(1000...10000)}@gmail.com"))
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))

    create_stripe_customer_from_token(
      @user,
      new_stripe_token(CARD_WILL_FAIL)
    )

    # USE WHEN GETTING INVOICE ALREADY PAID ERROR
    delete_stripe_payment_method(@user)

    @trial_expires_in = 60.seconds
    activate_expire_soon_subscription(@user, @region, @subscription, @trial_expires_in)

    make_stripe_subscription_trial_end_soon(@user, @trial_expires_in)
    wait_for_trial_expire(@trial_expires_in)

    @invoice = last_stripe_subscription_invoice(
      @user.stripe_subscription_id
    )
  end

  after do
    @user.destroy!
    @address.destroy!
    @region.destroy!
    @subscription.destroy!

    # RESTORE TEST DB BEFORE OTHER SPEC FILES RUN
    switch_db('test')
  end

  scenario 'subscription bill failed but charge is retryable (stripe automatic)' do
    pay_stripe_invoice(@invoice)

    # SMART RETRY ENABLED IN STRIPE SETTINGS TENDS TO TAKE LONGER TO SEND A INVOICE.PAYMENT_FAILED WEBHOOK SO WAIT LONGER
    p "#{'*' * rand(1..10)} WAITING FOR STRIPE TO SEND INVOICE.PAYMENT_FAILED WEBHOOK (TAKES LONGER WHEN SMART RETRIES IS ENABLED IN STRIPE SETTINGS)"
    sleep_with_feedback(180)
  end 

  # NO WAY TO TEST STRIPE AUTOMATIC RETRIES WTF
  # scenario 'maximum retries reached so stripe subscription is cancelled and the invoice is dead and a final email is sent informing the user' do
  #   # # SMART RETRY ENABLED IN STRIPE SETTINGS TENDS TO TAKE LONGER TO SEND A INVOICE.PAYMENT_FAILED WEBHOOK SO WAIT LONGER
  #   # p "#{'*' * rand(1..10)} WAITING FOR STRIPE TO SEND INVOICE.PAYMENT_FAILED WEBHOOK (TAKES LONGER WHEN SMART RETRIES IS ENABLED IN STRIPE SETTINGS)"
  #   # sleep_with_feedback(180)
  # end 
end