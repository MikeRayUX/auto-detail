require 'rails_helper'
require 'stripe_helper'
require 'webhook_helper'

RSpec.describe 'api/v1/users/current_payment_methods_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    @user = User.create!(attributes_for(:user).merge(
      email: Faker::Internet.email
    ))

    @auth_token = JsonWebToken.encode(sub: @user.id)
  end


  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  # NEW START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    get '/api/v1/users/current_payment_methods'

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user does not have a payment method so requires_payment_method is returned' do
    get '/api/v1/users/current_payment_methods', headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'requires_payment_method'
  end

  scenario 'user has a payment method so its safe_readable format is returned' do
    @token = new_stripe_token(CARD_VALID)
    create_stripe_customer_from_token(@user, @token)
    @user.reload

    get '/api/v1/users/current_payment_methods', 
      headers: {
        Authorization: @auth_token
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'payment_method_returned'
    expect(json[:payment_method]).to eq @user.readable_payment_method
  end
  # NEW END

  # UPDATE START
  scenario 'user does not have a payment method yet, so a new one is created by passing the new card details' do
    @token = new_stripe_token(CARD_VALID)
    put '/api/v1/users/current_payment_methods',
    params: {
      card: {
        stripe_token: @token.id,
        card_brand: 'visa',
        card_exp_month: '09',
        card_exp_year: '2024',
        card_last4: '6969'
      }
    },
    headers: {
      Authorization: @auth_token
    }
    @user.reload
    
    json = JSON.parse(response.body).with_indifferent_access

    @user.reload
    # response
    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'payment_method_saved'
    expect(json[:payment_method]).to eq @user.readable_payment_method
    # user
    @customer = retrieve_stripe_customer(@user)
    expect(@user.stripe_customer_id).to eq @customer.id
    expect(@user.card_brand).to eq 'visa'
    expect(@user.card_exp_month).to eq '09'
    expect(@user.card_exp_year).to eq '2024'
    expect(@user.card_last4).to eq '6969'
  end

  scenario 'user already has a payment method but enters a new card so the card details are updated on the user as well as stripe' do
    @visa_token = new_stripe_token(CARD_VALID)
    create_stripe_customer_from_token(@user, @visa_token.id)
    @user.reload

    @customer = retrieve_stripe_customer(@user)
    @old_card = @customer.sources.data.first
    expect(@user.card_brand).to eq @old_card.brand.to_s
    expect(@user.card_exp_month).to eq @old_card.exp_month.to_s
    expect(@user.card_exp_year).to eq @old_card.exp_year.to_s
    expect(@user.card_last4).to eq @old_card.last4.to_s

    @mastercard_token = new_stripe_token(CARD_VALID_MASTERCARD)
    put '/api/v1/users/current_payment_methods',
    params: {
      card: {
        stripe_token: @mastercard_token.id,
        card_brand: @mastercard_token.card.brand,
        card_exp_month: @mastercard_token.card.exp_month,
        card_exp_year: @mastercard_token.card.exp_year,
        card_last4: @mastercard_token.card.last4
      }
    },
    headers: {
      Authorization: @auth_token
    }
    
    json = JSON.parse(response.body).with_indifferent_access
    @user.reload
    # response
    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'payment_method_saved'
    expect(json[:payment_method]).to eq @user.readable_payment_method
    
    sleep 5.seconds
    # user
    @updated_customer = retrieve_stripe_customer(@user)
    @new_card = @customer.sources.data.first
    expect(@user.card_brand).to eq @new_card.brand.to_s
    expect(@user.card_exp_month).to eq @new_card.exp_month.to_s
    expect(@user.card_exp_year).to eq @new_card.exp_year.to_s
    expect(@user.card_last4).to eq @new_card.last4.to_s
  end
  # UPDATE END
end