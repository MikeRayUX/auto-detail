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

  # INDEX START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    sign_out @user

    get users_resolve_subscriptions_path

    expect(response).to redirect_to new_user_session_path
  end

  scenario 'user hasnt compelted setup (added an address)' do
    # before_action :completed_setup?

    get users_resolve_subscriptions_path

    expect(response).to redirect_to users_resolve_setups_path
  end

  scenario "user has an address, but it is outside service area and so they are redirected to outside coverage area page" do
    # before_action :address_within_region?

    @address = @user.create_address!(attributes_for(:address).merge(zipcode: '55555'))
    @address.attempt_region_attach

    get users_resolve_subscriptions_path

    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end
  # INDEX END

  # NEW START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    sign_out @user

    get new_users_resolve_subscription_path

    expect(response).to redirect_to new_user_session_path
  end

  scenario 'user hasnt compelted setup (added an address)' do
    # before_action :has_address?

    get new_users_resolve_subscription_path

    expect(response).to redirect_to users_resolve_setups_path
  end

  scenario "user has an address, but it is outside service area and so they are redirected to outside coverage area page" do
    # before_action :address_within_region?

    @address = @user.create_address!(attributes_for(:address).merge(zipcode: '55555'))
    @address.attempt_region_attach

    get new_users_resolve_subscription_path

    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end
  # NEW END
  
  # CREATE START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    sign_out @user

    post users_resolve_subscriptions_path, 
    params: {
      card: {
        card_brand: 'visa',
        card_exp_month: '04',
        card_exp_year: '04',
        card_last4: '4242',
        stripe_token: 'tok_visa'
      }
    }

    expect(response).to redirect_to new_user_session_path
  end

  scenario 'user hasnt compelted setup (added an address)' do
    # before_action :completed_setup?

    post users_resolve_subscriptions_path, 
    params: {
      card: {
        card_brand: 'visa',
        card_exp_month: '04',
        card_exp_year: '04',
        card_last4: '4242',
        stripe_token: 'tok_visa'
      }
    }

    expect(response).to redirect_to users_resolve_setups_path
  end

  scenario "user has an address, but it is outside service area and so they are redirected to outside coverage area page" do
    # before_action :address_within_region?

    @address = @user.create_address!(attributes_for(:address).merge(zipcode: '55555'))
    @address.attempt_region_attach

    post users_resolve_subscriptions_path, 
    params: {
      card: {
        card_brand: 'visa',
        card_exp_month: '04',
        card_exp_year: '04',
        card_last4: '4242',
        stripe_token: 'tok_visa'
      }
    }


    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end

  scenario 'a subscription is created successfully with a new payment method (card_params)' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    
    post users_resolve_subscriptions_path, 
    params: {
      card: {
        card_brand: 'visa',
        card_exp_month: '04',
        card_exp_year: '04',
        card_last4: '4242',
        stripe_token: 'tok_visa'
      }
    }

    @user.reload

    expect(response).to redirect_to users_resolve_subscription_path(id: 1)

    @user.reload
    # card/stripe customer
    expect(@user.stripe_customer_id).to be_present
    expect(@user.card_brand).to be_present
    expect(@user.card_exp_month).to be_present
    expect(@user.card_exp_year).to be_present
    expect(@user.card_last4).to be_present
    # transaction
    expect(@user.transactions.count).to eq 1
    @t = @user.transactions.last
    expect(@t.stripe_customer_id).to eq @user.stripe_customer_id
    expect(@t.stripe_subscription_id).to eq @user.stripe_subscription_id
    expect(@t.stripe_charge_id).to eq @user.stripe_subscription_id
    expect(@t.paid).to eq 'paid'
    expect(@t.card_brand).to eq @user.card_brand
    expect(@t.card_exp_month).to eq @user.card_exp_month
    expect(@t.card_exp_year).to eq @user.card_exp_year
    expect(@t.card_last4).to eq @user.card_last4
    expect(@t.customer_email).to eq @user.email
    expect(@t.subtotal).to eq @subscription.price
    expect(@t.tax).to eq @subscription.tax(@region.tax_rate)
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.grandtotal).to eq @subscription.grandtotal(@region.tax_rate)
    expect(@t.region_name).to eq @region.area
    # subscription
    expect(@user.stripe_subscription_id).to be_present
    expect(@user.subscription_activated_at.today?).to eq true
    expect(@user.subscription_expires_at).to be_present
  end 

  scenario 'user tries to create another subcription but already has one activated' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    create_stripe_customer!

    @user.activate_subscription!(Subscription.first)
    
    post users_resolve_subscriptions_path

    expect(response).to redirect_to new_users_resolve_subscription_path

    expect(flash[:notice]).to eq 'You already have an active subscription.'
  end 

  scenario 'user has a payment method already but no subscription so no card params are passed and a subscription is created and charged successfully with existing card' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    create_stripe_customer!
    
    post users_resolve_subscriptions_path

    expect(response).to redirect_to users_resolve_subscription_path(id: 1)

    @user.reload
    # card/stripe customer
    expect(@user.stripe_customer_id).to be_present
    expect(@user.card_brand).to be_present
    expect(@user.card_exp_month).to be_present
    expect(@user.card_exp_year).to be_present
    expect(@user.card_last4).to be_present
    # transaction
    expect(@user.transactions.count).to eq 1
    @t = @user.transactions.last
    expect(@t.stripe_customer_id).to eq @user.stripe_customer_id
    expect(@t.stripe_subscription_id).to eq @user.stripe_subscription_id
    expect(@t.stripe_charge_id).to eq @user.stripe_subscription_id
    expect(@t.paid).to eq 'paid'
    expect(@t.card_brand).to eq @user.card_brand
    expect(@t.card_exp_month).to eq @user.card_exp_month
    expect(@t.card_exp_year).to eq @user.card_exp_year
    expect(@t.card_last4).to eq @user.card_last4
    expect(@t.customer_email).to eq @user.email
    expect(@t.subtotal).to eq @subscription.price
    expect(@t.tax).to eq @subscription.tax(@region.tax_rate)
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.grandtotal).to eq @subscription.grandtotal(@region.tax_rate)
    expect(@t.region_name).to eq @region.area
    # subscription
    expect(@user.stripe_subscription_id).to be_present
    expect(@user.subscription_activated_at.today?).to eq true
    expect(@user.subscription_expires_at).to be_present
  end 

  scenario 'user canceled their stripe subscription and now reactivates' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    create_stripe_customer!

    @user.activate_subscription!(@subscription)

    @user.reload
    @stripe_subscription_id = @user.stripe_subscription_id

    @user.cancel_subscription!
    
    post users_resolve_subscriptions_path

    expect(response).to redirect_to users_resolve_subscription_path(id: 1)

    @user.reload
    # card/stripe customer
    expect(@user.stripe_customer_id).to be_present
    expect(@user.stripe_subscription_id).to_not eq @stripe_subscription_id
    expect(@user.card_brand).to be_present
    expect(@user.card_exp_month).to be_present
    expect(@user.card_exp_year).to be_present
    expect(@user.card_last4).to be_present
    # transaction
    expect(@user.transactions.count).to eq 2
    @t = @user.transactions.last
    expect(@t.stripe_customer_id).to eq @user.stripe_customer_id
    expect(@t.stripe_subscription_id).to eq @user.stripe_subscription_id
    expect(@t.stripe_charge_id).to eq @user.stripe_subscription_id
    expect(@t.paid).to eq 'paid'
    expect(@t.card_brand).to eq @user.card_brand
    expect(@t.card_exp_month).to eq @user.card_exp_month
    expect(@t.card_exp_year).to eq @user.card_exp_year
    expect(@t.card_last4).to eq @user.card_last4
    expect(@t.customer_email).to eq @user.email
    expect(@t.subtotal).to eq @subscription.price
    expect(@t.tax).to eq @subscription.tax(@region.tax_rate)
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.grandtotal).to eq @subscription.grandtotal(@region.tax_rate)
    expect(@t.region_name).to eq @region.area
    # # subscription
    expect(@user.stripe_subscription_id).to be_present
    expect(@user.subscription_activated_at.today?).to eq true
    expect(@user.subscription_expires_at).to be_present
  end 

  scenario 'user has a payment method, but wants to use a new card to pay for their subscription so their stripe payment method is updated' do
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    create_stripe_customer!
    
    post users_resolve_subscriptions_path,
    params: {
      card: {
        card_brand: 'mastercard',
        card_exp_month: '05',
        card_exp_year: '25',
        card_last4: '5151',
        stripe_token: 'tok_mastercard'
      }
    }

    expect(response).to redirect_to users_resolve_subscription_path(id: 1)

    @user.reload
    # card/stripe customer
    expect(@user.stripe_customer_id).to be_present
    expect(@user.card_brand).to eq 'mastercard'
    expect(@user.card_exp_month).to eq '05'
    expect(@user.card_exp_year).to eq '25'
    expect(@user.card_last4).to eq '5151'
    # subscription
    expect(@user.stripe_subscription_id).to be_present
    expect(@user.subscription_activated_at.today?).to eq true
    expect(@user.subscription_expires_at).to be_present
    # transaction
    expect(@user.transactions.count).to eq 1
    @t = @user.transactions.last
    expect(@t.stripe_customer_id).to eq @user.stripe_customer_id
    expect(@t.stripe_subscription_id).to eq @user.stripe_subscription_id
    expect(@t.stripe_charge_id).to eq @user.stripe_subscription_id
    expect(@t.paid).to eq 'paid'
    expect(@t.card_brand).to eq @user.card_brand
    expect(@t.card_exp_month).to eq @user.card_exp_month
    expect(@t.card_exp_year).to eq @user.card_exp_year
    expect(@t.card_last4).to eq @user.card_last4
    expect(@t.customer_email).to eq @user.email
    expect(@t.subtotal).to eq @subscription.price
    expect(@t.tax).to eq @subscription.tax(@region.tax_rate)
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.grandtotal).to eq @subscription.grandtotal(@region.tax_rate)
    expect(@t.region_name).to eq @region.area
  end 
  # CREATE END
end
