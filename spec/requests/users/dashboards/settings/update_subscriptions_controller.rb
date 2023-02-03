# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'users/resolve_subscriptions_controller', type: :request do
  before do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
    
    @region = create(:region)
    
    @subscription = create(:subscription)

		@coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(
			region_id: @region.id
		))

    @password = Faker::Internet.password
    
    @user = create(:user)
    sign_in @user
  end

  after do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user has never subscribed and is redirected to create a subscription' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    # create_stripe_customer!

    get users_dashboards_settings_update_subscriptions_path

    page = response.body

    expect(response).to redirect_to users_resolve_subscriptions_path
  end

  scenario 'user has an active subscription' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    # create_stripe_customer!

    @user.update(attributes_for(:user, :with_active_subscription))

    get users_dashboards_settings_update_subscriptions_path

    page = response.body

    expect(page).to include @user.readable_subscription_activated_at
    expect(page).to include @user.readable_subscription_renewell_date
    expect(page).to include "Cancel Subscription"
  end

  scenario 'users subscription is expired and is redirected to create a subscription' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    # create_stripe_customer!

    @user.update(attributes_for(:user, :sub_expired))

    get users_dashboards_settings_update_subscriptions_path

    expect(response).to redirect_to users_resolve_subscriptions_path
  end

  scenario 'user cancels their stripe subscription' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    create_stripe_customer!

    @user.activate_subscription!(@subscription)
    
    delete users_dashboards_settings_update_subscriptions_path(id: 1)

    @user.reload
    # card/stripe customer
    expect(@user.stripe_customer_id).to be_present
    expect(@user.stripe_subscription_id).to eq nil
    # # subscription
    expect(@user.stripe_subscription_id).to eq nil
    expect(@user.subscription_activated_at).to eq nil
    expect(@user.subscription_expires_at).to eq nil

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.first
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    expect(@email.subject).to eq 'Subscription Cancelled | FRESHANDTUMBLE'

    # email body
    expect(@html_email).to include(@user.formatted_name)
    expect(@text_email).to include(@user.formatted_name)

    expect(@html_email).to include('has been cancelled successfully.')
    expect(@text_email).to include('has been cancelled successfully.')
  end 

  scenario 'users stripe subscription failed payment, their subscription is expired, they updated their payment method, and stripe auto retries the payment' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    create_stripe_customer!

    @user.activate_subscription!(@subscription)

    @stripe_subscription_id = @user.stripe_subscription_id
    
    delete users_dashboards_settings_update_subscriptions_path(id: 1)

    @user.reload
    # card/stripe customer
    expect(@user.stripe_customer_id).to be_present
    expect(@user.stripe_subscription_id).to eq nil
    # # subscription
    expect(@user.stripe_subscription_id).to eq nil
    expect(@user.subscription_activated_at).to eq nil
    expect(@user.subscription_expires_at).to eq nil

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.first
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    expect(@email.subject).to eq 'Subscription Cancelled | FRESHANDTUMBLE'

    # email body
    expect(@html_email).to include(@user.formatted_name)
    expect(@text_email).to include(@user.formatted_name)

    expect(@html_email).to include('has been cancelled successfully.')
    expect(@text_email).to include('has been cancelled successfully.')
  end 
end
