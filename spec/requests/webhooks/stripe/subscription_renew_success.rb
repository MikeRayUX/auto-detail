# 1. THE HOOK IS IN ANOTHER ENVIRONMENT (DEVELOPMENT). THE HOOK WILL NOT SEE THE USER STRIPE CUSTOMER ID OR SUBSCRIPTION ID UNLESS CHANGES IN SPEC ARE ACTUALLY SAVED TO THE DEVELOPMENT DB, AS IT IS NOT PERMANENTLY SAVED WHEN TRANSACTIONAL FIXTURES IS SET TO TRUE (SET BY DEFAULT IN RAILS_HELPER)

# 2. REQUIRES STRIPE-CLI RUNNING, AUTHORIZED, AND LISTENING IN ORDER TO FORWARD WEBHOOK REQUESTS FROM STRIPE TO APP ON LOCALHOST
# example: 
# 'stripe listen --api-key sk_test_0d4LHDkpMBhESxsqudQXGMMW --forward-to 192.168.0.12:3000/

require 'no_transactional_fixtures'
require 'webhook_helper'
require 'stripe_helper'
RSpec.describe 'webhooks/stripe/stripe_subscription_renew_success', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    # CONNECT TO DEVELOPMENT DB
    switch_db('development')

    
    ActionMailer::Base.deliveries.clear
    
    @region = Region.create!(attributes_for(:region))

    @subscription = Subscription.create!(attributes_for(:subscription))

    @user = User.create!(attributes_for(:user).merge(email: "customer#{rand(1000...10000)}@gmail.com"))

    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
  end

  after do
    @user.destroy!
    @address.destroy!
    @region.destroy!
    @subscription.destroy!

    # RESTORE TEST DB
    switch_db('test')
  end

  scenario 'users subscription is renewed' do
    create_stripe_customer_from_token(@user, new_stripe_token(CARD_VALID))
    @user.activate_subscription!(@subscription)
    let_webhook_finish

    @user.reload

    p "activated_at: #{Time.at(@user.subscription_activated_at).to_datetime.strftime('%m/%d/%Y at %I:%M%P')}"
    p "expires_at: #{Time.at(@user.subscription_expires_at).to_datetime.strftime('%m/%d/%Y at %I:%M%P')}"

    expect(@user.subscription_expires_at).to be_present
    expect(@user.subscription_activated_at).to be_present
    expect(@user.stripe_subscription_id).to be_present

    # email NOT YET ABLE TO SEE IN DEVELOPMENT MODE
    # expect(ActionMailer::Base.deliveries.count).to eq 1	    expect(ActionMailer::Base.deliveries.count).to eq 1
    # @email = ActionMailer::Base.deliveries.first	    @email = ActionMailer::Base.deliveries.first
    # @html_email = @email.html_part.body	    @html_email = @email.html_part.body
    # @text_email = @email.text_part.body	    @text_email = @email.text_part.body
    # expect(@email.to).to eq [@user.email]
    # expect(@email.from).to eq ['no-reply@freshandtumble.com']
    # expect(@email.subject).to eq 'Your Subscription | FRESHANDTUMBLE'

    # # email body
    # expect(@html_email).to include(@user.formatted_name)
    # expect(@text_email).to include(@user.formatted_name)

    # expect(@html_email).to include('You can now start a pickup immediately by visiting your dashboard')
    # expect(@text_email).to include('You can now start a pickup immediately by visiting your dashboard')

    # expect(@html_email).to include(@user.subscription_activated_at.strftime('%m/%d/%Y'))
    # expect(@text_email).to include(@user.subscription_activated_at.strftime('%m/%d/%Y'))

    # expect(@html_email).to include((@user.subscription_activated_at + 1.month).strftime('%m/%d/%Y'))
    # expect(@text_email).to include((@user.subscription_activated_at + 1.month).strftime('%m/%d/%Y'))

    # expect(@html_email).to include(@subscription.price)
    # expect(@text_email).to include(@subscription.price)

    # expect(@html_email).to include(@region.tax_rate_percentage)
    # expect(@text_email).to include(@region.tax_rate_percentage)

    # expect(@html_email).to include(@subscription.tax(@region.tax_rate))
    # expect(@text_email).to include(@subscription.tax(@region.tax_rate))

    # expect(@html_email).to include(format('%.2f', @subscription.grandtotal(@region.tax_rate)))
    # expect(@text_email).to include(format('%.2f', @subscription.grandtotal(@region.tax_rate)))

    # expect(@html_email).to include(@user.readable_payment_method)
    # expect(@text_email).to include(@user.readable_payment_method)
  end 

  scenario 'users stripe subscripton failed to be billed, the user updates their payment method to a valid card and stripe bills the subscription successfully reactivating their subscription and refreshing its expiry' do
    create_stripe_customer_from_token(
      @user, 
      new_stripe_token(CARD_VALID)
    )

    # USE WHEN GETTING INVOICE ALREADY PAID ERROR
    delete_stripe_payment_method(@user)

    @trial_expires_in = 60.seconds
    activate_expire_soon_subscription(@user, @region, @subscription, @trial_expires_in)

    make_stripe_subscription_trial_end_soon(@user, @trial_expires_in)
    wait_for_trial_expire(@trial_expires_in)

    # make subscription expired on our end
    @user.update(
      subscription_activated_at: DateTime.current - 1.month,
      subscription_expires_at: DateTime.current - 1.days
    )

    # force failed payment
    @invoice = last_stripe_subscription_invoice(
      @user.stripe_subscription_id
    )
    pay_stripe_invoice(@invoice)

    # SMART RETRY ENABLED IN STRIPE SETTINGS TENDS TO TAKE LONGER TO SEND A INVOICE.PAYMENT_FAILED WEBHOOK SO WAIT LONGER
    p "#{'*' * rand(1..10)} WAITING FOR STRIPE TO SEND INVOICE.PAYMENT_FAILED WEBHOOK (TAKES LONGER WHEN SMART RETRIES IS ENABLED IN STRIPE SETTINGS)"
    sleep_with_feedback(180)

    # USER UPDATES THEIR PAYMENT METHOD WITH ONE THATS VALID (stripe should automatically bill now)
    update_stripe_payment_method(@user, new_stripe_token(CARD_VALID))

    p "#{'*' * rand(1..10)} WAITING FOR STRIPE TO AUTOMATICALLY BILL THE INVOICE AND SEND A INVOICE.PAYMENT_SUCCEEDED WEBHOOK EVENT"
    sleep_with_feedback(10)

    @user.reload

    expect(@user.subscription_activated_at.today?).to eq true
  end

end
