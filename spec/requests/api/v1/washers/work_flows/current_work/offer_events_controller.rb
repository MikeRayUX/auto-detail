require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/workflows/current_work/offer_events_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_open_offers(1)
    @offer = NewOrder.first
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is not logged in' do
    # before_action :authenticate_washer!

    post '/api/v1/washers/work_flows/current_work/offer_events', 
    headers: {
      Authorization: ''
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'washer is not activated' do
    # before_action :washer_activated?
    @w.deactivate!

    post '/api/v1/washers/work_flows/current_work/offer_events', 
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'not_activated'
  end


  scenario 'order is not found' do
    # before_action :order_exists?
    @new_order.take_washer(@w)
    post '/api/v1/washers/work_flows/current_work/offer_events',{
      params: {
        new_order: {
          ref_code: 'asdasdfafsd'
        }
      },
      headers: {
        Authorization: @auth
      }
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'order_not_found'
  end

  scenario 'offer event is created sucesffully' do
    @event_type = OfferEvent.event_types.to_a.sample.first
    @feedback = 'asdfasdf'

    @new_order.take_washer(@w)
    post '/api/v1/washers/work_flows/current_work/offer_events',{
      params: {
        new_order: {
          ref_code: @new_order.ref_code
        },
        offer_event: {
          event_type: @event_type,
          feedback: @feedback
        }
      },
      headers: {
        Authorization: @auth
      }
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 201
    expect(json[:message]).to eq 'offer_event_created'

    @event = OfferEvent.first

    expect(@event.washer_id).to eq @w.id
    expect(@event.new_order_id).to eq @new_order.id
    expect(@event.event_type).to eq @event_type
    expect(@event.feedback).to eq @feedback
  end
end