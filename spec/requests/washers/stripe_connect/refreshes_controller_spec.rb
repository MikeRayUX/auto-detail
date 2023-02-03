require 'rails_helper'
RSpec.describe 'washers/stripe_connect/refreshes_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)

    @washer = Washer.new(attributes_for(:washer))
    @washer.skip_finalized_washer_attributes = true
    @washer.save
    @washer.disable_authenticate_with_otp

    @auth_token = JsonWebToken.encode(sub: @washer.email)

    @region = create(:region, :open_washer_capacity)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    @new_account = Stripe::Account.create({
      type: 'express',
      country: 'US',
      email: @washer.email,
      capabilities: {
        transfers: {requested: true},
        tax_reporting_us_1099_misc: {requested: true}
      }
    })

    @washer.update(stripe_account_id: @new_account.id)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'washer has not completed their stripe account setup so a link to stripe wizard is returned' do

    get washers_stripe_connect_refreshes_path(id: @washer.stripe_account_id)

    page = response.body

    expect(page).to include 'Please visit this link to complete your direct deposit setup through stripe'
    expect(page).to include 'Go To Stripe'
  end

  # scenario 'washer has already coompleted their setup so they not given a stripe link button' do

  #   get washers_stripe_connect_refreshes_path(id: @washer.stripe_account_id)

  #   page = response.body

  #   expect(page).to include 'Please visit this link to complete your direct deposit setup through stripe'
  #   expect(page).to include 'Go To Stripe'
  # end

end