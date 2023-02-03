require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/offers/open_offers_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    #  {lat: 47.62082130182253, lng: -122.3493162189335}

    DatabaseCleaner.clean_with(:truncation)

    setup_activated_washer_spec
    create_open_offers(@region.max_concurrent_offers + 1)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
  end

  scenario 'washer is not logged in' do
    # before_action :authenticate_washer!
    get '/api/v1/washers/offers/open_offers', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body).with_indifferent_access
    expect(json[:status]).to eq 'unauthorized'
  end

  scenario 'washer is not activated' do
    # before_action :check_activation_status
    @w.deactivate!

    get '/api/v1/washers/offers/open_offers', {
      headers: {
        Authorization: @auth
      }
    }

    json = JSON.parse(response.body).with_indifferent_access
    expect(json[:message]).to eq 'not_activated'
  end

  scenario 'there are open offers but the washer currently has one or more pending asap pickups so offer_already_in_progress' do
    # before_action :no_asap_offers_pending_pickup
    NewOrder.first.take_washer(@w)

    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: 47.62082130182253,
          lng: -122.3493162189335
        }
        },
      headers: {
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'offer_already_pending_pickup'
  end

  scenario 'washer has accepted multiple offers and none of them are pending pickup (theyve been picked up already) but the maximum concurrent accept count has been reached' do
    # before_action :under_max_concurrent_asap_offers
    NewOrder.all.limit(@region.max_concurrent_offers).each do |o|
      o.take_washer(@w)
    end

    expect(@w.new_orders.count).to eq @region.max_concurrent_offers

    expect(@w.new_orders.pending_pickup.count).to eq @region.max_concurrent_offers

    @w.new_orders.pending_pickup.each do |o|
      o.update(picked_up_at: DateTime.current)
    end
    expect(@w.new_orders.pending_pickup.count).to eq 0


    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: 47.62082130182253,
          lng: -122.3493162189335
        }
        },
      headers: {
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'max_offers_reached'
  end

  
  scenario 'there are offers but they have expired so none_available is returned' do
    # before_action :offers_available?

    travel_to(DateTime.current + NewOrder::ACCEPT_LIMIT + 1.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: '',
          lng: ''
        }
      },
      headers: {
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'none_available'
  end

  scenario 'there are no open offers currently and a none_available message is returned' do
    # before_action :offers_available?

    NewOrder.destroy_all

    get '/api/v1/washers/offers/open_offers', headers: {
      Authorization: @auth
    }
 
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'none_available'

    @region.reload
    expect(@region.last_washer_offer_check > 10.seconds.ago).to be_present
  end

  scenario 'all offers have been cancelled so none_available is returned' do
    # before_action :offers_available?

    NewOrder.all.each do |o|
      o.soft_cancel
    end
   
    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: 47.62082130182253,
          lng: -122.3493162189335
        }
        },
      headers: {
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'none_available'

    # region
    @region = @w.region
    expect(@region.last_washer_offer_check).to be_present
  end
  
  scenario 'there are open offers and the washer is activated' do

    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: 47.62082130182253,
          lng: -122.3493162189335
        }
        },
      headers: {
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_available'
    expect(json[:offers].count).to eq @count

    # offers
    json[:offers].each do |o|
      # presence
      expect(o[:ref_code]).to be_present
      expect(o[:scheduled]).to_not be_present
      expect(o[:readable_scheduled]).to_not be_present
      expect(o[:bags_to_scan]).to be_present
      expect(o[:pay]).to be_present
      expect(o[:return_by]).to be_present
      expect(o[:total_seconds]).to be_present
      expect(o[:seconds_to_accept]).to be_present
      expect(o[:percent_left]).to be_present
      expect(o[:distance]).to be_present
      expect(o[:zipcode]).to be_present
    end
  end

  scenario 'washer has multiple in progress offers and they are all picked up and the current accepted offers are under the max asap offer limit, so open offers are returned' do
    NewOrder.first.take_washer(@w)
    NewOrder.first.update(picked_up_at: DateTime.current)

    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: 47.62082130182253,
          lng: -122.3493162189335
        }
        },
      headers: {
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_available'
  end

  scenario 'scheduled offer is shown, scheduled attributes are returned' do
    NewOrder.destroy_all

    @count = 1

    create_scheduled_open_offers(@count)
    
    get '/api/v1/washers/offers/open_offers', 
    params: {
      current_location: {
        lat: 47.62082130182253,
        lng: -122.3493162189335
      }
      },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_available'
    expect(json[:offers].count).to eq @count

    o = json[:offers].first

    expect(o[:scheduled]).to be_present
    expect(o[:readable_scheduled]).to be_present
    expect(o[:ref_code]).to be_present
    expect(o[:bags_to_scan]).to be_present
    expect(o[:pay]).to be_present
    expect(o[:return_by]).to be_present
    expect(o[:total_seconds]).to be_present
    expect(o[:seconds_to_accept]).to be_present
    expect(o[:percent_left]).to be_present
    expect(o[:distance]).to be_present
    expect(o[:zipcode]).to be_present
  end

  scenario 'washer lat long location data is not sent so an unknown distance is returned' do
    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: '',
          lng: ''
        }
      },
      headers: { 
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_available'
    expect(json[:offers].count).to eq @count

    # offers
    json[:offers].each do |o|
      # presence
      expect(o[:distance]).to eq 'Unknown'
    end
  end

  scenario 'nil lat long location data is not sent so an unknown distance is returned' do
    travel_to(DateTime.current + 10.minutes) do
      get '/api/v1/washers/offers/open_offers', 
      params: {
        current_location: {
          lat: nil,
          lng: nil
        }
      },
      headers: { 
        Authorization: @auth
      }
    end

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offers_available'
    expect(json[:offers].count).to eq @count

    # offers
    json[:offers].each do |o|
      # presence
      expect(o[:distance]).to eq 'Unknown'
    end
  end
end