require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/work_flows/current_work/abandon_offers_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_scheduled_open_offers(1)
    @offer = NewOrder.first
    @offer.take_washer(@w)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is not activated' do
    # before_action :check_activation_status
    @w.update(attributes_for(:washer, :deactivated))
    put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'not_activated'
    expect(json[:errors]).to eq 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
  end

  scenario "offer doesn't exist" do
    # before_action :offer_exists?
    @offer.update(washer_id: nil)
    put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'offer_not_found'
  end

  scenario "washer tries to abandon offer twice offer_not_found is returned" do
    # before_action :offer_exists?
    put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    } 

    put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'offer_not_found'
  end

  scenario "offer was already cancelled by customer" do
    # before_action :is_scheduled?
    @offer.update(pickup_type: 'asap')

    put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'offer_not_found'
  end

  scenario "offer was already cancelled by customer" do
    # before_action :not_cancelled?
    @offer.update(status: 'cancelled')

    put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    } 

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'offer_already_cancelled'
  end

  scenario 'the offer is abandoned early (more than 45 minutes from the pickup time) so there is no penalty. an sms notification is also sent to all washers of new offer drop (except washer who dropped)' do
    travel_to(@offer.est_pickup_by - (NewOrder::ABANDON_LIMIT + 1.minutes)) do
      put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      } 
  
      json = JSON.parse(response.body).with_indifferent_access
  
      expect(json[:code]).to eq 204
      expect(json[:message]).to eq 'offer_abandoned'
  
      # offer
      @offer.reload
      expect(@offer.washer_id).to eq nil
      # available for other washers to accept
      expect(@offer.status).to eq 'created'
      # offer_event
      expect(@offer.offer_events.count).to eq 1
      expect(@w.offer_events.count).to eq 1
      @event = @offer.offer_events.last
      expect(@event.washer_id).to eq @w.id
      expect(@event.new_order_id).to eq @offer.id
      expect(@event.event_type).to eq 'offer_abandoned'
    end
  end

  scenario 'the offer is abandoned late (less than 45 minutes from the pickup time) so there is no penalty an sms notification is also sent to all washers of new offer drop (except washer who dropped)' do
    @washer_2 = Washer.create!(attributes_for(:washer, :activated).merge(
      region_id: @region.id,
      email: Faker::Internet.email,
      phone: '4055555555'
      # phone: '2066369875'
    ))

    travel_to(@offer.est_pickup_by + 4.minutes) do
      put '/api/v1/washers/work_flows/current_work/abandon_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      } 
  
      json = JSON.parse(response.body).with_indifferent_access
  
      expect(json[:code]).to eq 204
      expect(json[:message]).to eq 'offer_abandoned'

      # offer
      @offer.reload
      expect(@offer.washer_id).to eq nil
      # available for other washers to accept
      expect(@offer.status).to eq 'created'
      # offer_event
      expect(@offer.offer_events.count).to eq 1
      expect(@w.offer_events.count).to eq 1
      @event = @offer.offer_events.last

      expect(@event.washer_id).to eq @w.id
      expect(@event.new_order_id).to eq @offer.id
      expect(@event.event_type).to eq 'offer_abandoned'
    end
  end
end