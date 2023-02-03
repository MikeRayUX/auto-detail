# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'deliver to customer controller step3s', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
		ActionMailer::Base.deliveries.clear
		@region = create(:region)
    @pricing = create(:region_pricing)
    @user = User.create!(attributes_for(:user).merge(
      card_brand: 'visa',
      card_exp_month: '05',
      card_exp_year: '2024',
      card_last4: '4242'
    ))

    @address = @user.create_address!(attributes_for(:address))

    @worker = create(:worker, :with_region)

    @new_bags_code = get_new_bags_code

    @bags_collected = rand(1..5)

    @courier_weight = get_random_weight

    @order = @user.orders.create!(
      attributes_for(:order).merge(
        region_pricing_id: @pricing.id,
        full_address: @address.full_address,
        routable_address: @address.address,
        bags_code: @new_bags_code,
        bags_collected: @bags_collected,
        courier_weight: @courier_weight
    ))

    @partner_location = @order.create_partner_location(attributes_for(:partner_location))

    @random_invoice_number = get_new_bags_code

    @order.mark_picked_up_from_partner

    @order.mark_arrived_at_customer_for_delivery
    @order.mark_scanned_existing_bags_for_delivery

    sign_in @worker
  end

  after do
    ActionMailer::Base.deliveries.clear
    sign_out @worker
  end

  scenario 'worker views the delivery location questionaire' do
    get workers_courier_tasks_deliver_to_customer_step3_path(id: @order.id)

    @page = response.body

    expect(@page).to include('Where are you leaving the order?')
    expect(@page).to include(@user.formatted_phone)
  end

  scenario 'order is delivered successfully and the customer is notified via sms and email' do
    create_stripe_customer!

    @location = get_random_delivery_location

    put workers_courier_tasks_deliver_to_customer_step3_path, params: {
      id: @order.id,
      delivery_location: @location
    }

    @order.reload
    
    # order
    expect(@order.global_status).to eq('delivered')
		# transaction
    
		# notification
		@notification = Notification.first
    expect(@user.notifications.count).to eq(1)
    expect(@order.notifications.count).to eq(1)
    expect(@notification.event).to eq('order_delivered')
    expect(@notification.message_body).to eq('Your Fresh And Tumble Laundry has been delivered! - So Fresh And Clean!')
    expect(@notification.sent).to eq(true)
    expect(@notification.sent_at).to be_present
		expect(@notification.notification_method).to eq('sms')
		# email
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  scenario 'the delivery form is submitted twice but the u ser is only notified once' do
    create_stripe_customer!

    @location = get_random_delivery_location

    2.times do
      put workers_courier_tasks_deliver_to_customer_step3_path, params: {
        id: @order.id,
        delivery_location: @location
      }
    end

    @order.reload
    
		@notification = Notification.first
    expect(@user.notifications.count).to eq(1)
    expect(@order.notifications.count).to eq(1)
	end
	
  scenario 'worker does not provide a delivery location and is kicked back' do
    put workers_courier_tasks_deliver_to_customer_step3_path, params: {
      id: @order.id,
      delivery_location: ''
    }

    expect(flash[:notice]).to eq('You must provide a valid delivery location.')
    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step3_path(id: @order.id)
  end
end
