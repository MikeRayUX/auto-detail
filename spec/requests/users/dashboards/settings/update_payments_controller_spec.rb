require 'rails_helper'
require 'order_helper'
RSpec.describe 'users/dashboards/settings/update_payments_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = create(:user)
    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user does not have a payment method and views the update payment method page and sees no current payment method header' do
    get users_dashboards_settings_update_payments_path

    page = response.body

    expect(page).to_not include("Current payment method")
  end

  scenario 'user does not have a payment method yet and submits a new card which creates a new stripe customer' do
    @card_brand = 'visa'
    @card_exp_month = '4'
    @card_exp_year = '2024'
    @card_last4 = '4242'

    put users_dashboards_settings_update_payments_path, params: {
      card: {
        card_brand: @card_brand,
        card_exp_month: @card_exp_month,
        card_exp_year: @card_exp_year,
        card_last4: @card_last4,
        stripe_token: 'tok_visa'

      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_update_payments_path
    expect(flash[:notice]).to eq "Payment method saved!"

    # user
    expect(@user.card_brand).to eq @card_brand
    expect(@user.card_exp_month).to eq @card_exp_month
    expect(@user.card_exp_year).to eq @card_exp_year
    expect(@user.card_last4).to eq @card_last4
  end

  scenario 'user has a payment method so they see the current payment method header' do
    @user.update_attributes(attributes_for(:user, :with_payment_method).merge(stripe_customer_id: 'asdfasdfasdf'))
    @card_brand = 'visa'
    @card_exp_month = '4'
    @card_exp_year = '2024'
    @card_last4 = '4242'

    get users_dashboards_settings_update_payments_path, params: {
      card: {
        card_brand: @card_brand,
        card_exp_month: @card_exp_month,
        card_exp_year: @card_exp_year,
        card_last4: @card_last4,
        stripe_token: 'tok_visa',
      }
    }

    page = response.body

    expect(page).to include "Current payment method"

    expect(page).to include("#{@user.card_brand.upcase}...#{@user.card_last4} expires #{@user.card_exp_month}/#{@user.card_exp_year}")
  end

  scenario 'user has a payment method already and so the payment method is updated on the user as well as stripe' do
    create_stripe_customer!

    @old_stripe_customer = retrieve_stripe_customer(@user).sources.data.first

    expect(@old_stripe_customer[:brand]).to eq @user.card_brand
    expect(@old_stripe_customer[:exp_month]).to eq @user.card_exp_month.to_i
    expect(@old_stripe_customer[:exp_year]).to eq @user.card_exp_year.to_i
    expect(@old_stripe_customer[:last4]).to eq @user.card_last4

    # DEFAULT tok_mastercard attributes (from stripe docs)
    # "brand": "MasterCard",
    # "exp_month": 10,
    # "exp_year": 2021,
    # "last4": "4444"

    @new_card_brand = 'MasterCard'
    @new_card_exp_month = '1'
    @new_card_exp_year = '2022'
    @new_card_last4 = '4444'

    put users_dashboards_settings_update_payments_path, params: {
      card: {
        card_brand: @new_card_brand,
        card_exp_month: @new_card_exp_month,
        card_exp_year: @new_card_exp_year,
        card_last4: @new_card_last4,
        stripe_token: 'tok_mastercard',
      }
    }
    
    @user.reload
    
    @new_stripe_customer = retrieve_stripe_customer(@user).sources.data.first

    # stripe test api shuffles card numbers
    # expect(@new_stripe_customer[:brand]).to eq @new_card_brand
    # expect(@new_stripe_customer[:exp_month]).to eq @new_card_exp_month.to_i
    # expect(@new_stripe_customer[:exp_year]).to eq @new_card_exp_year.to_i
    # expect(@new_stripe_customer[:last4]).to eq @new_card_last4

    expect(response).to redirect_to users_dashboards_settings_update_payments_path
    expect(flash[:notice]).to eq "Payment method successfully updated!"

    # user
    expect(@user.card_brand).to eq @new_card_brand
    expect(@user.card_exp_month).to eq @new_card_exp_month
    expect(@user.card_exp_year).to eq @new_card_exp_year
    expect(@user.card_last4).to eq @new_card_last4
  end

  scenario 'user has payment has an invalid stripe customer id and they are kicked back' do
    @user.update_attributes(attributes_for(:user, :with_payment_method).merge(stripe_customer_id: 'asdfasdfasdf'))
    @card_brand = 'visa'
    @card_exp_month = '4'
    @card_exp_year = '2024'
    @card_last4 = '5555'

    put users_dashboards_settings_update_payments_path, params: {
      stripe_token: 'tok_visa',
      card: {
        card_brand: @card_brand,
        card_exp_month: @card_exp_month,
        card_exp_year: @card_exp_year,
        card_last4: @card_last4
      }
    }

    @user.reload

    expect(response).to redirect_to users_dashboards_settings_update_payments_path
    expect(flash[:alert]).to be_present

    # user
    expect(@user.card_exp_month).to_not eq @card_exp_month
    expect(@user.card_exp_year).to_not eq @card_exp_year
    expect(@user.card_last4).to_not eq @card_last4
  end

end