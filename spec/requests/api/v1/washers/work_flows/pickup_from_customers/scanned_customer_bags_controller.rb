require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/work_flow/pickup_from_customers/scanned_customer_bags_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_open_offers(1)

    @new_order.take_washer(@w)
    @new_order.mark_arrived_for_pickup
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check' do
    put '/api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'the washer passes codes that match the bag count and the order is updated' do
    @codes_params = []

    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end

    @compacted_codes = @codes_params.split(',').join('/')

    put '/api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1', params: {
      new_order: {
        ref_code: @new_order.ref_code,
        bag_codes: @codes_params.to_json
      }
    }, 
    headers: {
        Authorization: @auth
      }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 204
    expect(json['message']).to eq 'picked_up_successfully'

    
    @new_order.reload
    expect(@new_order.bag_codes).to eq @compacted_codes
    expect(@new_order.picked_up_at).to be_present
    expect(@new_order.status).to eq 'picked_up'

    # offer_event

    @event = OfferEvent.last
    expect(@event.washer_id).to eq @w.id
    expect(@event.new_order_id).to eq @new_order.id
    @minutes = ((@new_order.est_pickup_by - @new_order.picked_up_at) / 60).to_i
    expect(@event.feedback).to eq "(#{@minutes} MINUTES EARLY)"
      
    # notification
    @n = Notification.first
		expect(@n.new_order_id).to eq @new_order.id
		expect(@n.notification_method).to eq 'sms'
		expect(@n.event).to eq 'order_picked_up'
		expect(@n.sent).to eq true
		expect(@n.sent_at).to be_present
		expect(@n.message_body).to eq  "#{@w.abbrev_name} just picked up your laundry. Enjoy your fresh laundry in less than 24 hours!"
		expect(@new_order.notifications.where(event: 'order_picked_up').count).to eq 1
  end

  scenario 'washer picks up the order late' do
    travel_to(@new_order.est_pickup_by + 60.minutes) do
      @codes_params = []

      @new_order.bag_count.times do
        @codes_params.push(SecureRandom.hex(2).upcase)
      end

      @compacted_codes = @codes_params.split(',').join('/')

      put '/api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1', params: {
        new_order: {
          ref_code: @new_order.ref_code,
          bag_codes: @codes_params.to_json
        }
      }, 
      headers: {
          Authorization: @auth
        }
      
      json = JSON.parse(response.body)

      expect(json['code']).to eq 204
      expect(json['message']).to eq 'picked_up_successfully'

      
      @new_order.reload
      expect(@new_order.bag_codes).to eq @compacted_codes
      expect(@new_order.picked_up_at).to be_present
      expect(@new_order.status).to eq 'picked_up'

      # offer_event

      @event = OfferEvent.last

      expect(@event.washer_id).to eq @w.id
      expect(@event.new_order_id).to eq @new_order.id
      @minutes = ((@new_order.picked_up_at - @new_order.est_pickup_by) / 60).to_i
      expect(@event.feedback).to eq "(#{@minutes} MINUTES LATE)"
    end
  end

  scenario 'order has already been marked as picked up and codes were passed, so an already_picked_up error is returned' do
    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(JSON.parse(@codes_params.to_json))

    put '/api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1', params: {
      new_order: {
        ref_code: @new_order.ref_code,
        bag_codes: ['asdfasd', '3sdfeas'].to_json
      }
    }, 
    headers: {
        Authorization: @auth
      }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'already_picked_up'
    @new_order.reload
    expect(@new_order.bag_codes).to eq @codes_params.split(',').join('/')
    expect(@new_order.picked_up_at).to be_present
    expect(@new_order.status).to eq 'picked_up'
  end

  scenario 'no codes are passed so an error is returned' do
    put '/api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1', params: {
      new_order: {
        ref_code: @new_order.ref_code,
        bag_codes: ''
      }
    }, 
    headers: {
        Authorization: @auth
      }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'missing_codes'
    @new_order.reload
    expect(@new_order.bag_codes).to eq nil
    expect(@new_order.picked_up_at).to_not be_present
    expect(@new_order.status).to eq 'arrived_for_pickup'
  end

  scenario 'code count does not match order bag count so an error is returned' do
    @codes_params = []
    (@new_order.bag_count - 1).times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    put '/api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1', params: {
      new_order: {
        ref_code: @new_order.ref_code,
        bag_codes: @codes_params.to_json
      }
    }, 
    headers: {
        Authorization: @auth
      }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'codes_do_not_match'
    @new_order.reload
    expect(@new_order.bag_codes).to eq nil
    expect(@new_order.picked_up_at).to_not be_present
    expect(@new_order.status).to eq 'arrived_for_pickup'
  end
end