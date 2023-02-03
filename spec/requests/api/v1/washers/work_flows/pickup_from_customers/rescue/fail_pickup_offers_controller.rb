require 'rails_helper'
require 'offer_helper'
require 'order_helper'
RSpec.describe 'api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    setup_payoutable_washer_spec
    create_open_offers(1)
    
    @problems = [
      {
        event_type: 'cannot_locate_order_address_access_pickup',
        feedback: 'Cannot access address or residential location',
      },
      {
        event_type: 'cannot_locate_order_business_closed_pickup',
        feedback: 'Business is closed',
      },
      {
        event_type: 'customer_cancelled_pickup',
        feedback: 'Customer cancelled',
      },
      {
        event_type: 'all_bags_missing_pickup',
        feedback: 'Cannot pick up. All bags missing for this Order',
      }
    ];

    @new_order.take_washer(@w)
    @new_order.mark_arrived_for_pickup
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'washer is not logged in' do
    # before_action :authenticate_washer!
    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'invalid order ref_code' do
    # before_action :ensure_order_exists
    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', {
    params: { 
      new_order: {
        ref_code: 'asdfafsd'
      },
    },
      headers: {
        Authorization: @auth
      }
    }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_not_found'
  end

  scenario 'washer no longer has connection to order for whatever reason' do
    # before_action :ensure_order_exists
    @new_order.drop_washer

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', {
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
    },
      headers: {
        Authorization: @auth
      }
    }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_not_found'
  end

  scenario 'washer attempts to cancel pickup when an order is in an invalid state ' do
    # before_action :ensure_status
    @new_order.mark_enroute_for_pickup

    @problem = @problems.sample

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', 
      params: { 
        new_order: {
          ref_code: @new_order.ref_code
        },
        offer_event: {
          event_type: @problem[:event_type],
          feedback: @problem[:feedback],
        }
      },
      headers: {
        Authorization: @auth
      }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'invalid_order_status'
  end 

  scenario 'washer tries to cancel multiple times' do
    # before_action :ensure_order_exists
    create_stripe_customer!
    charge_new_order!(@user, @new_order)

    @problem = @problems.sample

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
      offer_event: {
        event_type: @problem[:event_type],
        feedback: @problem[:feedback],
      }
    },
      headers: {
        Authorization: @auth
      }

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
      offer_event: {
        event_type: @problem[:event_type],
        feedback: @problem[:feedback],
      }
    },
      headers: {
        Authorization: @auth
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_not_found'
  end

  scenario 'washer is payoutable_as_ic indicates that the order cannot be picked up for various reasons, the order is cancelled and they are paid 7$ for their time, the order is also partially refunded (minus the 7$ fee)' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)

    @problem = @problems.sample

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
      offer_event: {
        event_type: @problem[:event_type],
        feedback: @problem[:feedback],
      }
    },
      headers: {
        Authorization: @auth
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'pickup_failed_successfully'

    # # NEWORDER
    @new_order.reload
    expect(@new_order.arrived_for_pickup_at).to be_present
    expect(@new_order.arrived_for_pickup_at > 10.seconds.ago).to eq true
    expect(@new_order.status).to eq 'cancelled'
    
    @failed_pickup_fee = @region.failed_pickup_fee

    # # transfer/payout
    expect(@new_order.stripe_transfer_id).to be_present
    expect(@new_order.washer_final_pay.to_i).to eq @failed_pickup_fee
    expect(@new_order.payout_desc).to eq "Unable To Pickup: $#{format('%.2f', (@failed_pickup_fee))}"
    @stripe_transfer = @new_order.get_stripe_transfer
    expect(@stripe_transfer.amount).to eq (@failed_pickup_fee * 100).to_i
    
    # # # refund
    @stripe_transaction = @new_order.get_stripe_transaction
    expect(@new_order.stripe_refund_id).to be_present
    @stripe_refund = @new_order.get_stripe_refund
    expect(@stripe_refund.amount).to eq @stripe_transaction.amount - (@failed_pickup_fee * 100).to_i

    # offer_event
    @offer_event = OfferEvent.first
    expect(@offer_event.washer_id).to eq @w.id
    expect(@offer_event.new_order_id).to eq @new_order.id
    expect(@offer_event.event_type).to eq @problem[:event_type]
    expect(@offer_event.feedback).to eq @problem[:feedback]

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.last
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.subject).to eq 'We were unable to pickup your order | FRESHANDTUMBLE'
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    # html_email
    expect(@html_email).to include "Our Washer was unable to pickup your order."
    expect(@html_email).to include @offer_event.feedback
    expect(@html_email).to include @offer_event.customer_reminder
    expect(@html_email).to include "$#{NewOrder.readable_decimal(@new_order.grandtotal)}"
    expect(@html_email).to include "$#{NewOrder.readable_decimal(@region.failed_pickup_fee)}"
    expect(@html_email).to include "$#{NewOrder.readable_decimal(@new_order.refunded_amount)}"
    # text_email
    expect(@text_email).to include "Our Washer was unable to pickup your order."
    expect(@text_email).to include @offer_event.feedback
    expect(@text_email).to include @offer_event.customer_reminder
  end

  scenario 'washer is not payoutable_as_ic so a transfer/payout is not made to the washer but the fee is still deducted from the refund' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)
    @old_grandtotal = @new_order.grandtotal

    @w.update(payoutable_as_ic: false)

    @problem = @problems.sample

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
      offer_event: {
        event_type: @problem[:event_type],
        feedback: @problem[:feedback],
      }
    },
      headers: {
        Authorization: @auth
      }

    json = JSON.parse(response.body).with_indifferent_access
    @new_order.reload

    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'pickup_failed_successfully'

    
    # stripe refund
    @failed_pickup_fee = @region.failed_pickup_fee

    @stripe_transaction = @new_order.get_stripe_transaction
    @stripe_refund_amount = @stripe_transaction.amount - (@failed_pickup_fee * 100).to_i
    @stripe_refund = @new_order.get_stripe_refund

    expect(@new_order.stripe_refund_id).to be_present
    expect(@stripe_refund.amount).to eq @stripe_refund_amount 
    # order refund
    @order_refund = @old_grandtotal - @failed_pickup_fee
    expect(@new_order.refunded_amount).to be_present
    expect(@new_order.refunded_amount).to eq @order_refund

    # # transfer/payout
    expect(@new_order.stripe_transfer_id).to_not be_present

    # # NEWORDER
    expect(@new_order.arrived_for_pickup_at).to be_present
    expect(@new_order.arrived_for_pickup_at > 10.seconds.ago).to eq true
    expect(@new_order.status).to eq 'cancelled'
    expect(@new_order.cancelled_at > 10.seconds.ago).to eq true
    

    # offer_event
    @offer_event = OfferEvent.first
    expect(@offer_event.washer_id).to eq @w.id
    expect(@offer_event.new_order_id).to eq @new_order.id
    expect(@offer_event.event_type).to eq @problem[:event_type]
    expect(@offer_event.feedback).to eq @problem[:feedback]

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.last
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.subject).to eq 'We were unable to pickup your order | FRESHANDTUMBLE'
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    # html_email
    expect(@html_email).to include "Our Washer was unable to pickup your order."
    expect(@html_email).to include @offer_event.feedback
    expect(@html_email).to include @offer_event.customer_reminder
    expect(@html_email).to include "$#{NewOrder.readable_decimal(@new_order.grandtotal)}"
    expect(@html_email).to include "$#{NewOrder.readable_decimal(@region.failed_pickup_fee)}"
    expect(@html_email).to include "$#{NewOrder.readable_decimal(@new_order.refunded_amount)}"
    # text_email
    expect(@text_email).to include "Our Washer was unable to pickup your order."
    expect(@text_email).to include @offer_event.feedback
    expect(@text_email).to include @offer_event.customer_reminder
  end

end