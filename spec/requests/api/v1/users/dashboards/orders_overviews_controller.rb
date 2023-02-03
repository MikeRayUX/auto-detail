# frozen_string_literal: true
require 'rails_helper'
require 'order_helper'
require 'offer_helper'
require 'format_helper'
RSpec.describe 'api/v1/users/dashboards/orders_overviews_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)

    @region = create(:region)

    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(region_id: @region.id))

    @user = create(:user, :with_invalid_stripe)
    @auth_token = JsonWebToken.encode(sub: @user.id)

    @address = @user.build_address(
      attributes_for(:address, :with_fake_geocode)
    )
    @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach
    
    setup_washer
    create_open_offers(1)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'user is not signed in' do
    get '/api/v1/users/dashboards/orders_overviews'

    json = JSON.parse(response.body).with_indifferent_access
    
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user has no orders yet and sees the mini tutorial flash message' do
    NewOrder.destroy_all

    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'no_orders'
  end

  scenario 'user creates a new order and can view its default status' do
    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'has_orders'
    # orders
    expect(json[:orders]).to be_present
    expect(json[:orders].length).to eq @user.new_orders.length
    # order
    @order = @user.new_orders.last
    @json_order = json[:orders].first
    expect(@json_order[:ref_code]).to eq @order.ref_code
    expect(@json_order[:created_at]).to eq readable_date(@order.created_at)
    expect(@json_order[:grandtotal]).to eq readable_decimal(@order.grandtotal)
    expect(@json_order[:bag_count]).to eq @order.bag_count
    expect(@json_order[:scheduled]).to eq nil
    expect(@json_order[:readable_status]).to eq @order.readable_status
    expect(@json_order[:detergent]).to eq @order.short_detergent
    expect(@json_order[:softener]).to eq @order.short_softener
    expect(@json_order[:est_delivery]).to eq @order.readable_est_delivery
    expect(@json_order[:readable_delivered]).to eq @order.readable_delivered
  end

  # # NEW ORDERS START
  scenario 'new_order has been accepted by washer and the status does not change and still links to pickup tracker page' do
    @new_order.take_washer(@w)

    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'has_orders'
    # orders
    expect(json[:orders]).to be_present
    expect(json[:orders].length).to eq @user.new_orders.length
    expect(json[:orders].first[:readable_status]).to eq 'Pending Pickup'
  end

  scenario 'new_order has not been picked up but the waher is enroute for pickup so the status is shown and it contains a link to return to the pickup tracker page' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup

    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'has_orders'
    # orders
    expect(json[:orders]).to be_present
    expect(json[:orders].length).to eq @user.new_orders.length
    expect(json[:orders].first[:readable_status]).to eq 'Pending Pickup'
  end

  scenario 'washer has arrived, the status should remain unchanged' do
    @new_order.take_washer(@w)
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup

    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }
    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'has_orders'
    # orders
    expect(json[:orders]).to be_present
    expect(json[:orders].length).to eq @user.new_orders.length
    expect(json[:orders].first[:readable_status]).to eq 'Pending Pickup'
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
    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }
    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'has_orders'
    # orders
    expect(json[:orders]).to be_present
    expect(json[:orders].length).to eq @user.new_orders.length
    expect(json[:orders].first[:readable_status]).to eq "Picked up on #{@new_order.picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
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

    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }
    json = JSON.parse(response.body).with_indifferent_access

     # response
     expect(json[:code]).to eq 200
     expect(json[:message]).to eq 'has_orders'
     # orders
     expect(json[:orders]).to be_present
     expect(json[:orders].length).to eq @user.new_orders.length
     expect(json[:orders].first[:readable_status]).to eq "Delivered on #{@new_order.delivered_at.strftime('%m/%d/%Y at %I:%M%P')}"
  end

  scenario 'New order has been cancelled, so a cancelled status is shown' do
    @new_order.update(cancelled_at: DateTime.current, status: 'cancelled')
    
    get '/api/v1/users/dashboards/orders_overviews',
    headers: {
      Authorization: @auth_token
    }
    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'has_orders'
    # orders
    expect(json[:orders]).to be_present
    expect(json[:orders].length).to eq @user.new_orders.length
    expect(json[:orders].first[:readable_status]).to eq "Cancelled"
  end
  # # NEW ORDERS END
  
end
