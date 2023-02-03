require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/work_flow/pickup_from_customers', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_open_offers(1)
    @new_order.take_washer(@w)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check' do
    put '/api/v1/washers/work_flows/pickup_from_customers/arrival_for_pickups/1', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'location is passed and is close enough so the order arrived_for_pickup and status attributes are updated as well as an sms notification is sent to the customer' do
    @new_order.mark_enroute_for_pickup

    put '/api/v1/washers/work_flows/pickup_from_customers/arrival_for_pickups/1', 
    params: { 
    new_order: {
      ref_code: @new_order.ref_code
    },
    current_location: {
      lat: 47.4987,
      lng: -122.3159
    }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 204
    expect(json['message']).to eq 'arrived_successfully'
    # NEWORDER
    @new_order.reload
    expect(@new_order.arrived_for_pickup_at).to be_present
    expect(@new_order.status).to eq 'arrived_for_pickup'

    @n = Notification.first

		expect(@n.new_order_id).to eq @new_order.id
		expect(@n.notification_method).to eq 'sms'
		expect(@n.event).to eq 'arrival_for_pickup'
		expect(@n.sent).to eq true
		expect(@n.sent_at).to be_present
		expect(@n.message_body).to eq  "#{@w.abbrev_name} has arrived for your laundry pickup."
		expect(@new_order.notifications.where(event: 'arrival_for_pickup').count).to eq 1
  end

  scenario 'no location is passed' do
    @new_order.mark_enroute_for_pickup

    put '/api/v1/washers/work_flows/pickup_from_customers/arrival_for_pickups/1', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
      current_location: {
        lat: '',
        lng: ''
      }
     },
     headers: {
       Authorization: @auth
     }

     json = JSON.parse(response.body)

     expect(json['code']).to eq 3000
     expect(json['message']).to eq 'missing_location'

     # NEWORDER 
     @new_order.reload

     expect(@new_order.arrived_for_pickup_at).to eq nil
     expect(@new_order.status).to eq 'enroute_for_pickup'
  end

  scenario 'location is passed but its not close enough' do
    @new_order.mark_enroute_for_pickup

    put '/api/v1/washers/work_flows/pickup_from_customers/arrival_for_pickups/1', 
    params: { 
    new_order: {
      ref_code: @new_order.ref_code
    },
    current_location: {
      lat: 47.4987,
      lng: -122.3155
    }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'not_close_enough'
    # NEWORDER
    @new_order.reload
    expect(@new_order.arrived_for_pickup_at).to eq nil
    expect(@new_order.status).to eq 'enroute_for_pickup'
  end

  scenario 'washer has already arrived once' do
    @new_order.mark_enroute_for_pickup
    @new_order.mark_arrived_for_pickup
    
    put '/api/v1/washers/work_flows/pickup_from_customers/arrival_for_pickups/1', 
    params: { 
    new_order: {
      ref_code: @new_order.ref_code
    },
    current_location: {
      lat: 47.4987,
      lng: -122.3155
    }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'already_arrived'
    # NEWORDER
    @new_order.reload
    expect(@new_order.status).to eq 'arrived_for_pickup'
  end
end