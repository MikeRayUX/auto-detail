# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
include Users::Orders::Chargeable

RSpec.describe 'pickup from customer step4s controller spec', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
		ActionMailer::Base.deliveries.clear
    @region = create(:region)
    @pricing = create(:region_pricing)

    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    @worker = create(:worker, :with_region)
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        region_pricing_id: @pricing.id,
        full_address: @address.full_address,
        routable_address: @address.address
    ))

    @appointment = @order.create_appointment!(
      pick_up_date: @order.pick_up_date, 
      pick_up_time: @order.pick_up_time
    )

    @code = get_new_reference_code

    @order.update_attributes(
      pick_up_from_customer_status: 'collected_customer_bags',
      bags_code: @code,
      bags_collected: rand(1..5)
    )
    sign_in @worker
  end

  after do
    sign_out @worker
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'worker submits valid weights and the customer is charged successfully' do  
    create_stripe_customer!

    @new_weight = rand(11..36.7).round(2)

    put workers_courier_tasks_pickup_from_customer_step4_path, params: {
      id: @order.id,
      weight: @new_weight
    }

    @order.reload

    @subtotal = get_subtotal(@order, @pricing)
    @tax = get_tax(@subtotal, @user)
    @grandtotal = get_grandtotal(@subtotal, @tax)

    expect(response).to redirect_to workers_dashboards_open_appointments_path
    expect(flash[:notice]).to eq 'Pickup was successful!'

    # order
		@order.reload
    expect(@order.global_status).to eq('picked_up')
    expect(@order.pick_up_from_customer_status).to eq('picked_up_from_customer')
    expect(@order.courier_weight).to eq(@new_weight)

    # appointment
    expect(@order.appointment).to be_present

    # transaction
    @t = @user.transactions.first
    expect(@user.transactions.count).to eq 1
    expect(@user.transactions.last.paid).to eq 'paid'
    expect(@t.weight).to eq(@new_weight)
    expect(@t.subtotal).to eq(@subtotal)
    expect(@t.tax).to eq(@tax)
    expect(@t.grandtotal).to eq(@grandtotal)
    expect(@t.stripe_customer_id).to eq(@user.stripe_customer_id)
    expect(@t.order_reference_code).to eq(@order.reference_code)
    expect(@t.wash_hours_saved).to eq @order.wash_hours_saved
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.region_name).to eq @region.area
    expect(@t.stripe_response).to eq 'success'
    expect(@t.stripe_charge_id).to be_present

    # notification
    @notification = @user.notifications.first
    expect(@user.notifications.count).to eq 1
    expect(@notification.event).to eq 'order_picked_up'
    expect(@notification.message_body).to eq 'Your Fresh And Tumble order has been picked up!'

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1

    @email = ActionMailer::Base.deliveries.first.html_part.body
  end
  
  scenario 'worker attempts to pick up but the customers payment was declined so a failed transaction is created, the courier is prompted to return the order, the order is cancelled, and a cancelled email is sent, and the customer received a returned order sms' do  
    @new_weight = rand(11..36.7).round(2)
    @user.update_attributes(attributes_for(:user, :with_invalid_stripe))

    put workers_courier_tasks_pickup_from_customer_step4_path, params: {
      id: @order.id,
      weight: @new_weight
    }

    @order.reload

    @subtotal = get_subtotal(@order, @pricing)
    @tax = get_tax(@subtotal, @user)
    @grandtotal = get_grandtotal(@subtotal, @tax)

    expect(response).to redirect_to workers_dashboards_open_appointments_path
    expect(flash[:notice]).to eq 'Pickup failed, return to customer'

    # order
    expect(@order.global_status).to eq('cancelled')
    expect(@order.pick_up_from_customer_status).to eq('rejected')
    expect(@order.courier_weight).to eq(@new_weight)
    # appointment
    expect(@order.appointment).to_not be_present
    # transaction
    @t = @user.transactions.first
    expect(@user.transactions.count).to eq 1
    expect(@user.transactions.last.paid).to eq 'failed'
    expect(@t.weight).to eq(@new_weight)
    expect(@t.subtotal).to eq(@subtotal)
    expect(@t.tax).to eq(@tax)
    expect(@t.grandtotal).to eq(@grandtotal)
    expect(@t.stripe_customer_id).to eq(@user.stripe_customer_id)
    expect(@t.order_reference_code).to eq(@order.reference_code)
    expect(@t.wash_hours_saved).to eq @order.wash_hours_saved
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.region_name).to eq @region.area
    # notification
    @notification = @user.notifications.first
    expect(@user.notifications.count).to eq 1
    expect(@notification.event).to eq 'pickup_rejected'
    expect(@notification.message_body).to eq 'Your Fresh And Tumble Order is being returned to you. Please check your email for more info.'
    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

  scenario 'worker submits failed transaction rejected form twice but only a single charge, sms, transaction, and emails were sent' do  
    @new_weight = rand(11..36.7).round(2)

    @user.update_attributes(attributes_for(:user, :with_invalid_stripe))

    2.times do
      put workers_courier_tasks_pickup_from_customer_step4_path, params: {
        id: @order.id,
        weight: @new_weight
      }
    end

    @order.reload

    @subtotal = get_subtotal(@order, @pricing)
    @tax = get_tax(@subtotal, @user)
    @grandtotal = get_grandtotal(@subtotal, @tax)

    expect(response).to redirect_to workers_dashboards_open_appointments_path

    expect(flash[:notice]).to eq 'This has already been submitted'

    # order
		@order.reload
    expect(@order.global_status).to eq('cancelled')
    expect(@order.pick_up_from_customer_status).to eq('rejected')
    expect(@order.courier_weight).to eq(@new_weight)

    # appointment
    expect(@order.appointment).to_not be_present

    # transaction
    @t = @user.transactions.first
    expect(@user.transactions.count).to eq 1
    expect(@user.transactions.last.paid).to eq 'failed'
    expect(@t.weight).to eq(@new_weight)
    expect(@t.subtotal).to eq(@subtotal)
    expect(@t.tax).to eq(@tax)
    expect(@t.grandtotal).to eq(@grandtotal)
    expect(@t.stripe_customer_id).to eq(@user.stripe_customer_id)
    expect(@t.order_reference_code).to eq(@order.reference_code)
    expect(@t.wash_hours_saved).to eq @order.wash_hours_saved
    expect(@t.tax_rate).to eq @region.tax_rate
    expect(@t.region_name).to eq @region.area

    # notification
    @notification = @user.notifications.first
    expect(@user.notifications.count).to eq 1
    expect(@notification.event).to eq 'pickup_rejected'
    expect(@notification.message_body).to eq 'Your Fresh And Tumble Order is being returned to you. Please check your email for more info.'

    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
	end
	
  scenario 'worker does not enter a valid weight and is redirected back' do  
    put workers_courier_tasks_pickup_from_customer_step4_path, params: {
      id: @order.id,
      weight: ''
    }

    expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step4_path(id: @order.id)
    expect(flash[:notice]).to eq('You must enter valid weights to continue.')
  end

  scenario 'worker does not enter a valid weight data type and is redirected back' do  
    put workers_courier_tasks_pickup_from_customer_step4_path, params: {
      id: @order.id,
      weight: 'asdfasdf'
    }

    expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step4_path(id: @order.id)
    expect(flash[:notice]).to eq('You must enter valid weights to continue.')
  end
end