require 'rails_helper'
require 'order_helper'
require 'offer_helper'
RSpec.describe 'users/dashboards/new_order_flow/cancel_pickups_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @region = create(:region, :open_washer_capacity)

    @user = create(:user, :with_active_subscription)
    sign_in @user

    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))

    @w = Washer.create!(attributes_for(:washer, :activated).merge(region_id: @region.id))
    @w.go_online
    @w.refresh_online_status

    create_open_offers(1)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'the order is waiting for washer, and is cancellable so it is cancelled and refund is issued' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)

    put '/users/dashboards/new_order_flow/cancel_pickups/1', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'order_cancelled'
    # order
    @new_order.reload
    expect(@new_order.status).to eq 'cancelled'
    expect(@new_order.cancelled_at).to be_present
    expect(@new_order.stripe_refund_id).to be_present

    # EMAILS
    @email = ActionMailer::Base.deliveries.last
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    expect(@email.subject).to eq 'Your Order Has Been Cancelled | FreshAndTumble'
    # html
    expect(@html_email).to include "Your Order (##{@new_order.ref_code}) has been cancelled successfully."
    expect(@html_email).to include "$#{format('%.2f', @new_order.grandtotal)}"
    expect(@html_email).to include @user.readable_payment_method
    expect(@html_email).to include "Please allow up to 48 hours for your refund to process, though it is common that you will receive your refund sooner."
    # text
    expect(@text_email).to include "Your Order (##{@new_order.ref_code}) has been cancelled successfully."
    expect(@text_email).to include "$#{format('%.2f', @new_order.grandtotal)}"
    expect(@text_email).to include @user.readable_payment_method
    expect(@text_email).to include "Please allow up to 48 hours for your refund to process, though it is common that you will receive your refund sooner."
  end

  scenario 'the order has already been cancelled! so it cannot be canceleld twice' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)
    
    @new_order.cancel!
    
    put '/users/dashboards/new_order_flow/cancel_pickups/1', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'not_cancellable'
    # order
    @new_order.reload
    expect(@new_order.status).to eq 'cancelled'
    expect(@new_order.cancelled_at).to be_present
    expect(@new_order.stripe_refund_id).to be_present
  end

  scenario 'the washer is enroute for pickup so it is not cancellable' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup
    
    put '/users/dashboards/new_order_flow/cancel_pickups/1', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'not_cancellable'
    # order
    @new_order.reload
    expect(@new_order.status).to eq 'enroute_for_pickup'
    expect(@new_order.cancelled_at).to_not be_present
    expect(@new_order.stripe_refund_id).to_not be_present
  end

  scenario 'the order has been picked up so it is not cancellable' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))
    
    put '/users/dashboards/new_order_flow/cancel_pickups/1', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'not_cancellable'
    # order
    @new_order.reload
    expect(@new_order.status).to eq 'picked_up'
    expect(@new_order.cancelled_at).to_not be_present
    expect(@new_order.stripe_refund_id).to_not be_present
  end

  scenario 'the order has been completed so it is not cancellable' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))
    @new_order.mark_completed
    
    put '/users/dashboards/new_order_flow/cancel_pickups/1', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'not_cancellable'
    # order
    @new_order.reload
    expect(@new_order.status).to eq 'completed'
    expect(@new_order.cancelled_at).to_not be_present
    expect(@new_order.stripe_refund_id).to_not be_present
  end

  scenario 'the order has been completed so it is not cancellable' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))
    @new_order.mark_completed
    @new_order.mark_delivered
    
    put '/users/dashboards/new_order_flow/cancel_pickups/1', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      }
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'not_cancellable'
    # order
    @new_order.reload
    expect(@new_order.status).to eq 'delivered'
    expect(@new_order.cancelled_at).to_not be_present
    expect(@new_order.stripe_refund_id).to_not be_present
  end
end