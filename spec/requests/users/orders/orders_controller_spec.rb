require 'rails_helper'
require 'order_helper'
RSpec.describe 'users/orders/orders_controller spec', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    @region = create(:region)
    @pricing = create(:region_pricing)
    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))

    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address
    ))

    @worker = create(:worker, :with_region)
    @appointment = @order.create_appointment!(
      pick_up_date: @order.pick_up_date,
      pick_up_time: @order.pick_up_time
    )

    sign_in @user
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    sign_out @user
  end

  scenario 'user views order show page' do
    get users_orders_orders_path, params: {
      reference_code: @order.reference_code
    }

    page = response.body

    expect(page).to include("Order - #{@order.reference_code}")
    expect(page).to include(@order.reference_code)
    expect(page).to include(@order.readable_created_at)
    expect(page).to include(@order.condensed_appointment)
    expect(page).to include(@order.readable_detergent)
    expect(page).to include(@order.readable_softener)
  end

  # scenario 'order is cancellable and the customer cancels it and the worker receives an sms cancellation notification' do
  #   put users_orders_orders_path, params: {
  #     reference_code: @order.reference_code
  #   }

  #   @order.reload

  #   expect(response).to redirect_to users_dashboards_orders_overviews_path
  #   expect(flash[:notice]).to eq "Your Order Has Been Cancelled."
  #   expect(Appointment.count).to eq 0
  #   expect(ActionMailer::Base.deliveries.count).to eq 1
  #   expect(@order.global_status).to eq 'cancelled'
  #   expect(@worker.notifications.count).to eq 1
  # end

  scenario 'order is not cancellable and so the user is kickec back' do
    @order.mark_pick_up_started
    put users_orders_orders_path, params: {
      reference_code: @order.reference_code
    }

    @order.reload

    expect(response).to redirect_to users_dashboards_orders_overviews_path
    expect(flash[:notice]).to eq "This Order Cannot Be Cancelled"
    expect(Appointment.count).to eq 1
    expect(ActionMailer::Base.deliveries.count).to eq 0
    expect(@order.global_status).to eq 'created'
  end

  scenario 'user passes another order id to cancel orders controller and is kicked back' do
    @order.mark_pick_up_started
    put users_orders_orders_path, params: {
      reference_code: ""
    }

    @order.reload

    expect(response).to redirect_to users_dashboards_orders_overviews_path
    expect(flash[:notice]).to eq "That order doesn't exist, or you don't have permission to view it."
  end

  scenario 'order has been billed and the customer can see the order total' do
    @user.update_attributes(attributes_for(:user, :with_payment_method))

    @weight = get_random_weight

    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
    )

    @order.reload

    mock_charged_order!

    get users_orders_orders_path, params: {
      reference_code: @order.reference_code
    }

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
  end

  scenario 'user views the page without passing the reference code as a param or removes reference_code= from the url and is kicked back' do
    get users_orders_orders_path, params: {
      reference_code: nil
    }

    page = response.body


    expect(response).to redirect_to users_dashboards_orders_overviews_path
    expect(flash[:notice]).to eq "That order doesn't exist, or you don't have permission to view it."
  end

  scenario "user passes an order reference code that doesn't exist and is kicked back" do
    get users_orders_orders_path, params: {
      reference_code: 'asdfasdfasfd'
    }

    page = response.body

    expect(response).to redirect_to users_dashboards_orders_overviews_path
    expect(flash[:notice]).to eq "That order doesn't exist, or you don't have permission to view it."
  end

  scenario "user tries to pass the reference code of another customer's order in the url and is kicked back" do
    @order2 = Order.create!(attributes_for(:order).merge(
      user_id: 2,
      reference_code: get_new_reference_code,
      full_address: 'asdfasdfasdf',
      routable_address: 'asl;dkjfas;ljdkf'
    ))

    get users_orders_orders_path, params: {
      reference_code: @order2.reference_code
    }
   
    page = response.body

    expect(response).to redirect_to users_dashboards_orders_overviews_path
    expect(flash[:notice]).to eq "That order doesn't exist, or you don't have permission to view it."
  end
end