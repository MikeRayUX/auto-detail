require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/work_flow/process_orders/wash_comletes', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_open_offers(1)

    @new_order.take_washer(@w)
    @new_order.mark_arrived_for_pickup
    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(@codes_params.to_json)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'auth check' do
    put '/api/v1/washers/work_flows/process_orders/wash_completes', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'washer marks order as completed' do
    travel_to(DateTime.current + 91.minutes) do
      put '/api/v1/washers/work_flows/process_orders/wash_completes', params: {
        new_order: {
          ref_code: @new_order.ref_code
        }
      },
      headers: {
        Authorization: @auth
      }
  
      json = JSON.parse(response.body)

      expect(json['code']).to eq 204
      expect(json['message']).to eq 'completed_successfully'
      # order
      @new_order.reload
      expect(@new_order.completed_at).to be_present
      expect(@new_order.status).to eq 'completed' 
    end
  end

  scenario 'washer passes an invalid ref code and an error is returned' do
    put '/api/v1/washers/work_flows/process_orders/wash_completes', params: {
      new_order: {
        ref_code: 'asdfasdf23rfs'
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body)

    expect(json['code']).to eq 3000
    expect(json['message']).to eq 'order_not_found'
    expect(json['errors']).to eq "This order cannot be found"
    # order
    @new_order.reload
    expect(@new_order.completed_at).to_not be_present
    expect(@new_order.status).to eq 'picked_up' 
  end

  scenario 'washer completes wash successfully' do

    travel_to(@new_order.picked_up_at + 30.minutes) {
      put '/api/v1/washers/work_flows/process_orders/wash_completes', params: {
        new_order: {
          ref_code: @new_order.ref_code
        }
      },
      headers: {
        Authorization: @auth
      }
  
      json = JSON.parse(response.body)
  
      expect(json['code']).to eq 204
      expect(json['message']).to eq 'completed_successfully'
      # order
      @new_order.reload
      expect(@new_order.completed_at).to be_present
      expect(@new_order.status).to eq 'completed' 
  
      # offer event
      @event = OfferEvent.last
      expect(@event.washer_id).to eq @w.id
      expect(@event.new_order_id).to eq @new_order.id
      expect(@event.event_type).to eq 'order_processed'
    }
  end
end