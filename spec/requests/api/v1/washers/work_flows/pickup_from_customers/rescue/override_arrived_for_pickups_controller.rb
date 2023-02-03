require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups_controller', type: :request do
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

  scenario 'washer is not logged in' do
    # before_action :ensure_order_exists
    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'invalid order ref_code' do
    # before_action :ensure_order_exists
    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups', {
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

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups', {
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

  scenario 'washer has already arrived (the app will navigate them to arrived/scan bags for pickup screen anyways)' do
    # before_action :ensure_status

    @new_order.mark_arrived_for_pickup

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups', {
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
    expect(json[:message]).to eq 'already_arrived'
  end 

  scenario 'washer indicates that they have arrived at the customer address but are unable to continue to the next screen but are allowed to continue via rescue step' do
    @new_order.mark_enroute_for_pickup

    @issues = [
      {
        feedback: "My GPS isn't working.",
        event_type: 'gps_arrived_problem_pickup',
      },
      {
        feedback: "I'm not sure.",
        event_type: 'gps_arrived_problem_pickup',
      },
    ];

    @issue = @issues.sample

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
      offer_event: {
        event_type: @issue[:event_type],
        feedback: @issue[:feedback],
      }
    },
      headers: {
        Authorization: @auth
      }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json['code']).to eq 204
    expect(json['message']).to eq 'arrived_successfully'
    # NEWORDER
    @new_order.reload
    expect(@new_order.arrived_for_pickup_at).to be_present
    expect(@new_order.status).to eq 'arrived_for_pickup'

    # notification
    @n = Notification.first
		expect(@n.new_order_id).to eq @new_order.id
		expect(@n.notification_method).to eq 'sms'
		expect(@n.event).to eq 'arrival_for_pickup'
		expect(@n.sent).to eq true
		expect(@n.sent_at).to be_present
		expect(@n.message_body).to eq  "#{@w.abbrev_name} has arrived for your laundry pickup."
    expect(@new_order.notifications.where(event: 'arrival_for_pickup').count).to eq 1
    
    # offer_event
    @offer_event = OfferEvent.first
    expect(@offer_event.washer_id).to eq @w.id
    expect(@offer_event.new_order_id).to eq @new_order.id
    expect(@offer_event.event_type).to eq @issue[:event_type]
    expect(@offer_event.feedback).to eq @issue[:feedback]
  end
end