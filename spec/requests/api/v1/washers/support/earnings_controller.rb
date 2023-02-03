require 'rails_helper'
require 'offer_helper'
require 'order_helper'
RSpec.describe 'api/v1/washers/support/earnings_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_open_offers(rand(1..6))
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check' do
    get '/api/v1/washers/support/earnings', headers: {Authorization: ''}

    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end
 
  scenario 'washer has no delivered orders so nothing is returned' do
   get '/api/v1/washers/support/earnings', headers: {Authorization: @auth}

   json = JSON.parse(response.body)

   expect(json['code']).to eq 200
   expect(json['message']).to eq 'no_completed_offers'
  end

  scenario 'washer has delivered orders(completed offers) and they are returned' do
    NewOrder.all.each do |o|
      o.take_washer(@w)
      o.mark_delivered
      o.update(stripe_transfer_id: 'aslidkfalsidfj')
    end

    get '/api/v1/washers/support/earnings', headers: {Authorization: @auth}
 
    json = JSON.parse(response.body).with_indifferent_access

    json[:offers].each do |o|
      p '*******************'
      p "ref code: #{o[:ref_code]}"
      p "payout desc: #{o[:payout_desc]}"
      p "readable_delivered_at: #{o[:readable_delivered_at]}"
      p "stripe_transfer_id: #{o[:stripe_transfer_id]}"
      p "stripe_transfer_error: #{o[:stripe_transfer_error]}"
    end
 
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_returned'
    expect(json[:offers].count).to eq @count
    expect(json[:offers].count).to eq NewOrder.count
   end

   scenario 'stripe transfer was successful and so the stripe transfer_id is returned' do
    # user
    create_stripe_customer!
    @new_order = NewOrder.first
    charge_new_order!(@user, @new_order)
    # washer
    @w.update(attributes_for(:washer, :payoutable))
    # order
    @new_order.take_washer(@w)
    @new_order.mark_delivered
    @new_order.payout_washer!

    get '/api/v1/washers/support/earnings', headers: {Authorization: @auth}
 
    json = JSON.parse(response.body).with_indifferent_access

   json[:offers].each do |o|
      p '*******************'
      p "ref code: #{o[:ref_code]}"
      p "payout desc: #{o[:payout_desc]}"
      p "readable_delivered_at: #{o[:readable_delivered_at]}"
      p "stripe_transfer_id: #{o[:stripe_transfer_id]}"
      p "stripe_transfer_error: #{o[:stripe_transfer_error]}"
    end

    # response 
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_returned'
    expect(json[:lifetime_earnings]).to be_present
    expect(json[:lifetime_earnings]).to eq @w.summed_earnings(@w.new_orders.payed_out)
    # offer
    @offer = json[:offers].first
    expect(json[:offers].count).to eq 1
    expect(@offer[:ref_code]).to eq @new_order.ref_code
    expect(@offer[:payout_desc]).to eq @new_order.payout_desc
    expect(@offer[:readable_delivered_at]).to eq @new_order.readable_delivered_at
    expect(@offer[:stripe_transfer_id]).to be_present
    expect(@offer[:stripe_transfer_error]).to_not be_present
   end

   scenario 'stripe transfer failed so a stripe error is returned allowing checking if error occured to display to the washer' do
    # user
    create_stripe_customer!
    @new_order = NewOrder.first
    charge_new_order!(@user, @new_order)
    # washer
    @new_order.take_washer(@w)
    @new_order.mark_delivered
    @new_order.payout_washer!

  rescue Stripe::StripeError => e
    @new_order.update(stripe_transfer_error: e)

    get '/api/v1/washers/support/earnings', headers: {Authorization: @auth}
 
    json = JSON.parse(response.body).with_indifferent_access

    # p json

    json[:offers].each do |o|
      p '*******************'
      p "ref code: #{o[:ref_code]}"
      p "payout desc: #{o[:payout_desc]}"
      p "readable_delivered_at: #{o[:readable_delivered_at]}"
      p "stripe_transfer_id: #{o[:stripe_transfer_id]}"
      p "stripe_transfer_error: #{o[:stripe_transfer_error]}"
    end

    # response 
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_returned'
    expect(json[:lifetime_earnings]).to be_present
    expect(json[:lifetime_earnings]).to eq  @w.summed_earnings(@w.new_orders.payout_failed)
    # offer
    @offer = json[:offers].first
    expect(json[:offers].count).to eq 1
    expect(@offer[:ref_code]).to eq @new_order.ref_code
    expect(@offer[:payout_desc]).to eq @new_order.payout_desc
    expect(@offer[:readable_delivered_at]).to eq @new_order.readable_delivered_at
    expect(@offer[:stripe_transfer_id]).to_not be_present
    expect(@offer[:stripe_transfer_error]).to be_present
   end
end