require 'rails_helper'
require 'order_helper'
require 'offer_helper'
RSpec.describe 'users/dashboards/new_order_flow/track_pickups_controller', type: :request do
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

  # GET STATUS (INDEX) START
  scenario 'an invalid order ref code is passed and an order not found message is returned' do
    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: 'safdawefasdf'
    }

    json = JSON.parse(response.body)

    expect(json['message']).to eq 'order_not_found'
    expect(json['order_status']).to eq 'order_not_found'
  end

  scenario 'the order offer is expired because a washer did not accept in time so offer_expired is returned allowing the customer to cancel/refund the order or continue waiting' do
    travel_to(DateTime.current + NewOrder::ACCEPT_LIMIT + 1.minute) do
      get users_dashboards_new_order_flow_track_pickups_path, params: {
        id: @new_order.ref_code
      }
  
      json = JSON.parse(response.body)
  
      expect(json['message']).to eq 'offer_expired'
      expect(json['order_status']).to eq 'offer_expired'
      expect(json['cancellable']).to eq true
    end
  end


  scenario 'the order is created, has not expired and is waiting for washer' do
    travel_to(DateTime.current + NewOrder::ACCEPT_LIMIT - 1.minute) do
      get users_dashboards_new_order_flow_track_pickups_path, params: {
        id: @new_order.ref_code
      }
  
      json = JSON.parse(response.body)

      expect(json['code']).to eq 200
      expect(json['message']).to eq 'order_returned'
      expect(json['order_status']).to eq 'created'
      expect(json['customer_status']).to eq 'Waiting for Courier'
      expect(json['washer']).to eq nil
      expect(json['est_pickup_by']).to eq @new_order.est_pickup_by.strftime('%I:%M%P').upcase
      expect(json['cancellable']).to eq true
    end
  end

  scenario 'the order has been accepted by washer but the washer is not yet enroute to customer for pickup so the washer location is not shared yet' do
    @new_order.take_washer(@w)

    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: @new_order.ref_code
    }

    json = JSON.parse(response.body)

    # order
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'order_returned'
    expect(json['order_status']).to eq 'washer_accepted'
    expect(json['customer_status']).to eq "Accepted by #{@new_order.washer.abbrev_name}"
    expect(json['cancellable']).to eq true
    expect(json['est_pickup_by']).to eq @new_order.est_pickup_by.strftime('%I:%M%P').upcase
    # washer
    expect(json['washer']).to_not be_present
  end

  scenario 'the washer is enroute_for_pickup an updated customer status is returned and the washer location is returned as well' do
    @new_order.take_washer(@w)
    # offers controller accept action
    @new_order.mark_enroute_for_pickup

    @lat = rand(1.234324..60)
    @lng = rand(1.234324..60)

    @w.update_location(@lat, @lng)

    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: @new_order.ref_code
    }

    json = JSON.parse(response.body)

    # order
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'order_returned'
    expect(json['order_status']).to eq 'enroute_for_pickup'
    expect(json['customer_status']).to eq "#{@w.abbrev_name} is on their way"
    expect(json['cancellable']).to eq false

    expect(json['est_pickup_by']).to eq @new_order.est_pickup_by.strftime('%I:%M%P').upcase
    # washer
    expect(json['washer']).to be_present
    expect(json['washer']['name']).to eq @w.abbrev_name
    expect(json['washer']['location']).to be_present
    expect(json['washer']['location']['lat']).to eq @lat
    expect(json['washer']['location']['lng']).to eq @lng
  end

  scenario 'the washer has arrived for pickup' do
    @new_order.take_washer(@w)
    # offers controller accept action
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup

    @lat = rand(1.234324..60)
    @lng = rand(1.234324..60)

    @w.update_location(@lat, @lng)

    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: @new_order.ref_code
    }

    json = JSON.parse(response.body)

    # order
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'order_returned'
    expect(json['order_status']).to eq 'arrived_for_pickup'
    expect(json['customer_status']).to eq "#{@w.abbrev_name} has arrived for pickup"
    expect(json['est_pickup_by']).to eq @new_order.est_pickup_by.strftime('%I:%M%P').upcase
    expect(json['cancellable']).to eq false
    # washer
    expect(json['washer']).to be_present
    expect(json['washer']['name']).to eq @w.abbrev_name
    expect(json['washer']['location']).to be_present
    expect(json['washer']['location']['lat']).to eq @lat
    expect(json['washer']['location']['lng']).to eq @lng
  end

  scenario 'the order was picked up so an estimated pickup by is nil since it has already been picked up' do
    @new_order.take_washer(@w)
    # offers controller accept action
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup
    

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))

    @lat = rand(1.234324..60)
    @lng = rand(1.234324..60)

    @w.update_location(@lat, @lng)

    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: @new_order.ref_code
    }

    json = JSON.parse(response.body)

    # order
    @new_order.reload
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'order_returned'
    expect(json['order_status']).to eq 'picked_up'
    expect(json['cancellable']).to eq false
    expect(json['customer_status']).to eq "Your laundry was picked up on #{@new_order.picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
    expect(json['est_pickup_by']).to eq nil
    expect(json['est_pickup_by']).to_not be_present
    # washer
    expect(json['washer']).to eq nil
  end

  scenario 'the order was picked up so an estimated pickup by is nil since it has already been picked up' do
    @new_order.take_washer(@w)
    # offers controller accept action
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup

    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))

    @lat = rand(1.234324..60)
    @lng = rand(1.234324..60)

    @w.update_location(@lat, @lng)

    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: @new_order.ref_code
    }

    json = JSON.parse(response.body)

    # order
    @new_order.reload
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'order_returned'
    expect(json['order_status']).to eq 'picked_up'
    expect(json['cancellable']).to eq false
    expect(json['customer_status']).to eq "Your laundry was picked up on #{@new_order.picked_up_at.strftime('%m/%d/%Y at %I:%M%P')}"
    expect(json['est_pickup_by']).to eq nil
    expect(json['est_pickup_by']).to_not be_present
    # washer
    expect(json['washer']).to eq nil
  end

  scenario 'the order was cancelled so order cancelled is returned' do
    @new_order.soft_cancel

    get users_dashboards_new_order_flow_track_pickups_path, params: {
      id: @new_order.ref_code
    }

    json = JSON.parse(response.body)

    # order
    @new_order.reload
    expect(json['code']).to eq 200
    expect(json['message']).to eq 'order_returned'
    expect(json['cancellable']).to eq false
    expect(json['order_status']).to eq 'cancelled'
    expect(json['customer_status']).to eq "Order Cancelled"
    # washer
  end

  scenario 'the order was cancelled and offer expired, but cancelled is returned' do
    travel_to(DateTime.current + 3.hours) do
      @new_order.soft_cancel

      get users_dashboards_new_order_flow_track_pickups_path, params: {
        id: @new_order.ref_code
      }

      json = JSON.parse(response.body)

      p json

      # order
      @new_order.reload
      expect(json['code']).to eq 200
      expect(json['message']).to eq 'order_returned'
      expect(json['cancellable']).to eq false
      expect(json['order_status']).to eq 'cancelled'
      expect(json['customer_status']).to eq "Order Cancelled"
      # washer
      end
  end
  # GET STATUS (INDEX) END
end