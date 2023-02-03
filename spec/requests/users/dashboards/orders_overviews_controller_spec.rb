# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
require 'offer_helper'
RSpec.describe 'orders overviews controller spec', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @region = create(:region)

    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    @pricing = create(:region_pricing)
    @user = create(:user, :with_invalid_stripe)
    @address = @user.build_address(
      attributes_for(:address, :with_fake_geocode)
    )
    @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach

    sign_in @user

    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address
    ))

    setup_washer
    create_open_offers(1)

    # delivered orders USED FOR GENERATION IN RB CONSOLE
    # rand(5..10).times do
    #   @user = User.first
    #   @address = @user.address
    #   @old_order = @user.orders.create!(
    #     FactoryBot.attributes_for(:order).merge(
    #       full_address: @address.full_address,
    #       routable_address: @address.address,
    #       courier_weight: @weight,
    #       picked_up_from_customer_at: DateTime.current,
    #       courier_stated_delivered_location: 'front_door',
    #       global_status: 'delivered',
    #       deliver_to_customer_status: 'delivered_to_customer',
    #       delivered_to_customer_at: DateTime.current
    #     ))
    # end
  end

  after do
    DatabaseCleaner.clean_with(:truncation)

    sign_out @user
  end

  scenario 'user has no orders yet and sees the mini tutorial flash message' do
    Order.destroy_all
    NewOrder.destroy_all

    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include("Once you place an order, you will be able to track it's progress here!")
  end

  scenario 'user creates a new order and can view its default status' do
    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include("Placed: #{@order.readable_created_at}")
    expect(page).to include("Appt: #{@order.condensed_appointment}")
    expect(page).to include("Est. Delivery: #{(@order.pick_up_date.tomorrow).strftime('%m/%d/%Y')} by 9pm")
  end

  scenario 'users order has been picked up and billed and can see the updated status as picked up on date and time' do
    @weight = get_random_weight
    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
    )

    @order.reload
    mock_charged_order!

    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include("Arrives #{@order.estimated_delivery}")
  end

  scenario 'order has been completed and delivered and the user can see the grandtotal as well as the delivered timestmap' do
    @weight = get_random_weight
    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
    )

    mock_charged_order!
    @order.update_attributes(
      courier_stated_delivered_location: 'front_door',
      global_status: 'delivered',
      deliver_to_customer_status: 'delivered_to_customer',
      delivered_to_customer_at: DateTime.current
    )
    @order.reload
    get users_dashboards_orders_overviews_path

    page = response.body

    # order
    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include("Delivered On: #{@order.readable_delivered}")
    # new_order
  end

  scenario 'The order delivery was delayed and the user can see the status as delayed' do
    @weight = get_random_weight
    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
    )

    @order.reload
    mock_charged_order!
    @order.mark_received_by_partner
    @order.mark_picked_up_from_partner
    @order.delay_delivery

    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include('Delayed')
  end

  scenario 'The order was unable to be delivered and the user sees that status as unable to deliver reattempting' do
    @weight = get_random_weight
    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
    )

    @order.reload
    mock_charged_order!
    @order.mark_received_by_partner
    @order.mark_picked_up_from_partner
    @order.mark_for_reattempt

    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include('Courier Unable To Deliver (Reattempting)')
  end

  scenario 'The order was cancelled by the customer or admin and they can see the status as cancelled' do
    @order.update_attribute(
      :global_status, 'cancelled'
    )
    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include("Appt: #{@order.condensed_appointment}")
    expect(page).to include('Cancelled')
  end

  scenario 'The courier was unable to pickup the order and the user sees the updated status as cancelled unable to pickup' do
    @order.update_attribute(
      :global_status, 'cancelled_unable_to_pickup'
    )
    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include("Appt: #{@order.condensed_appointment}")
    expect(page).to include('Cancelled: Courier Could Not Pick Up')
  end

  scenario 'The maximum delivery attempts have been made and the order is now in holding. The user can view the order staus as must pickup order manually' do
    @weight = get_random_weight
    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
      delivery_attempts: Order::DELIVERY_ATTEMPT_LIMIT
    )

    @order.reload
    mock_charged_order!
    @order.mark_received_by_partner
    @order.mark_picked_up_from_partner
    @order.mark_as_undeliverable
    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include('Cannot Deliver: Contact Support')
  end

  scenario 'The customer came to pick up the order manually and can view the updated status as completed' do
    @weight = get_random_weight
    @order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
      delivery_attempts: Order::DELIVERY_ATTEMPT_LIMIT
    )

    @order.reload
    mock_charged_order!
    @order.mark_received_by_partner
    @order.mark_picked_up_from_partner
    @order.mark_as_undeliverable
    @order.mark_picked_up_by_customer

    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include('Completed')
  end

  scenario 'user has an old delivered order as well as a new_order and can see both in their orders overviews' do
    @old_order = @order
    @weight = get_random_weight
    @old_order.update_attributes!(
      courier_weight: @weight,
      global_status: 'picked_up',
      picked_up_from_customer_at: DateTime.current,
    )

    mock_charged_order!
    @old_order.update_attributes(
      courier_stated_delivered_location: 'front_door',
      global_status: 'delivered',
      deliver_to_customer_status: 'delivered_to_customer',
      delivered_to_customer_at: DateTime.current
    )
    @old_order.reload


    get users_dashboards_orders_overviews_path

    page = response.body

    expect(page).to include(@order.readable_grandtotal)
    expect(page).to include(@order.readable_weight)
    expect(page).to include("Delivered On: #{@order.readable_delivered}")

  end

  # NEW ORDERS START
  scenario 'user has a new order (created) with pickup type asap which hasnt been picked up yet, so the item link will take them to the pickup flow page' do
    get users_dashboards_orders_overviews_path

    page = response.body

    @new_order = @user.new_orders.last

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Pending Pickup")
  end

  scenario 'new_order has been accepted by washer and the status does not change and still links to pickup tracker page' do
    @new_order.take_washer(@w)

    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Pending Pickup")
  end

  scenario 'new_order has not been picked up but the waher is enroute for pickup so the status is shown and it contains a link to return to the pickup tracker page' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup

    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Pending Pickup")
  end

  scenario 'washer is enroute to pickup new order so its status is unchanged but should still display the same data' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup

    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Pending Pickup")
  end

  scenario 'washer has arrived, the status should is unchanged' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup

    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Pending Pickup")
  end

  
  scenario 'new order has been completed but the status is displayed the same as picked up' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup
    @new_order.mark_completed

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))
    
    @new_order.reload
    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Picked up on #{@new_order.picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}")
  end

  scenario 'new_order has been delivered so the deliviered status is returned' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup
    @new_order.mark_completed

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))
    @new_order.mark_delivered
    
    @new_order.reload

    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    # link
    expect(page).to include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
    # status
    expect(page).to include("Delivered on #{@new_order.delivered_at.strftime('%m/%d/%Y at %I:%M%P')}")
  end

  scenario 'New order has been cancelled, so a cancelled status is shown' do
    @new_order.update(cancelled_at: DateTime.current, status: 'cancelled')
    
    get users_dashboards_orders_overviews_path
    page = response.body

    expect(page).to include(@new_order.ref_code)
    expect(page).to include("Cancelled")
    expect(page).to_not include("/users/dashboards/new_order_flow/track_pickups/#{@new_order.ref_code}")
  end
  # NEW ORDERS END
end
