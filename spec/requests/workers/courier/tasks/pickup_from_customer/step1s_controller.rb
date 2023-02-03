# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'pickup from customer step1s controller spec', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
		DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)

    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))
    @worker = create(:worker, :with_region)

    travel_to(Date.today.beginning_of_day) do
      @order = @user.orders.create!(
        attributes_for(:order).merge(
          pick_up_date: Date.today.strftime,
          pick_up_time: DateTime.parse(rand(1..59).minutes.from_now.to_s).strftime('%I:%M%p'),
          full_address: @address.full_address,
          routable_address: @address.address
      ))
    end
    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views the customers order information and address for traveling to customer to pickup order, this also sends a sms notification' do
    get workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
    }

    @page = response.body

    expect(@page).to include(@order.reference_code)
    expect(@page).to include(@order.user.full_name.upcase)
    expect(@page).to include(@order.full_address.upcase)
    expect(@page).to include(@order.condensed_appointment)
    expect(@page).to include(@order.condensed_appointment)
		expect(@page).to include(@address.readable_pickup_directions)
    expect(@page).to include(@order.google_nav_link)
    
    @order.reload

    expect(@order.pick_up_from_customer_status).to eq 'pick_up_from_customer_started'
		expect(@order.notifications.enroute_for_pickup.count).to eq 1
	end
	
	scenario 'worker starts the pickup twice but only a single sms notification is sent to the customer' do
		10.times do
			get workers_courier_tasks_pickup_from_customer_step1_path, params: {
				id: @order.id
			}
		end
		
		expect(@order.notifications.enroute_for_pickup.count).to eq 1
  end

  # scenario 'worker tries to start pickup more than an hour from the pickup time and is kicked back' do
  #   travel_to(Date.today.beginning_of_day) do
  #     @time = DateTime.parse(61.minutes.from_now.to_s).strftime('%I:%M%p')

  #     @order.update_attributes(
  #       pick_up_date: DateTime.current.strftime,
  #       pick_up_time: @time
  #     )

  #     get workers_courier_tasks_pickup_from_customer_step1_path, params: {
  #       id: @order.reference_code
  #     }

  #     expect(response).to redirect_to workers_dashboards_open_appointments_path
  #     expect(flash[:error]).to eq "Cannot start pickup. Either too early or order has been cancelled."
  #     expect(@user.notifications.count).to eq 0
  #   end
  # end

  scenario 'worker tries to start pickup but it was cancelled and is kicked back' do
    @order.update_attribute(:global_status, 'cancelled')

    get workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
    }

    expect(response).to redirect_to workers_dashboards_open_appointments_path
    expect(flash[:error]).to eq "Cannot start pickup. Either too early or order has been cancelled."
    expect(@user.notifications.count).to eq 0
  end

  scenario "worker clicks that they've arrived and the order status is updated" do
    patch workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
    }

    @order.reload

    expect(@order.pick_up_from_customer_status).to eq('arrived_at_customer_for_pickup')
		expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step2_path(id: @order.id)
  end

  scenario "customer has sms notifications enabled so they receive an sms that courier has arrived" do
    patch workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
		}

    @order.reload
		@notification = Notification.first
		
    expect(@user.notifications.count).to eq(1)
    expect(@order.notifications.count).to eq(1)
    expect(@notification.notification_method).to eq("sms")
    expect(@notification.message_body).to eq('Your Fresh And Tumble Courier has just arrived for pickup!')
    expect(@notification.event).to eq('arrival_for_pickup')
    expect(@notification.sent).to eq(true)
		expect(@notification.sent_at).to be_present
  end

  scenario "customer does not have sms notifications enabled so they don't get a notification" do
    @user.update_attribute(:sms_enabled, false)

    patch workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
    }

    expect(@user.notifications.count).to eq(0)
    expect(@order.notifications.count).to eq(0)
  end

  scenario "An sms notification has already been sent so the customer will not get two texts if the courier hits ive arrived more than once" do
    patch workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
    }

    patch workers_courier_tasks_pickup_from_customer_step1_path, params: {
      id: @order.id
    }

    expect(@user.notifications.count).to eq(1)
    expect(@order.notifications.count).to eq(1)
  end

end
