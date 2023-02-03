require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/offers/accept_offers_controller', type: :request do
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

  scenario 'washer is not activated' do
    # before_action :check_activation_status
    @w.deactivate!

    @new_order = NewOrder.all.sample

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @new_order.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:message]).to eq 'not_activated'
  end

  scenario 'washer is not logged in' do
    # before_action :authenticate_washer!

    @new_order = NewOrder.all.sample

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @new_order.ref_code
      }
    },
    headers: {
      Authorization: 'asdfasdf'
    }

    json = JSON.parse(response.body).with_indifferent_access
    expect(json[:status]).to eq 'unauthorized'
  end

  scenario 'washer has reached maximum in progress offers' do
    #  before_action :under_max_concurrent_asap_offers
    NewOrder.all.limit(@region.max_concurrent_offers).each do |o|
      o.take_washer(@w)
    end

    expect(@w.new_orders.count).to eq @region.max_concurrent_offers

    expect(@w.new_orders.pending_pickup.count).to eq @region.max_concurrent_offers

    @w.new_orders.pending_pickup.each do |o|
      o.update(picked_up_at: DateTime.current)
    end
    expect(@w.new_orders.pending_pickup.count).to eq 0


    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: NewOrder.last.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access
    
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'max_offers_reached'
  end

  

  scenario 'washer has asap offers pending so they cannot accept another asap offer' do
    NewOrder.all.limit(@region.max_concurrent_offers - 1).each do |o|
      o.take_washer(@w)
    end


    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: NewOrder.last.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'asap_offer_already_pending_pickup'
  end

  scenario 'washer tries to reset the order/offer status by re accepting an offer after it has already been picked up' do
    @offer = NewOrder.last
    @offer.take_washer(@w)

    @offer.update(picked_up_at: DateTime.current)

    expect(@offer.washer_id).to eq @w.id
    expect(@offer.status).to eq 'washer_accepted'

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    @offer.reload
    expect(@offer.washer_id).to eq @w.id
    expect(json[:message]).to eq 'already_taken'
  end

  scenario 'invalid ref code passed' do
    @offer = NewOrder.all.sample
    @offer.update(washer_id: 2, status: 'washer_accepted')

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: 'asdfasdf'
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    @offer.reload
    expect(@offer.washer_id).to eq 2
    expect(json[:message]).to eq 'already_taken'
  end

  scenario 'offer was already accepted by someone else so an already_taken message is returned' do
    @offer = NewOrder.all.sample
    @offer.update(washer_id: 2, status: 'washer_accepted')

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    @offer.reload
    expect(@offer.washer_id).to eq 2
    expect(json[:message]).to eq 'already_taken'
  end

  scenario 'washer tries to accept the same offer twice and is kicked back' do
    @offer = NewOrder.last
    @offer.take_washer(@w)

    expect(@offer.washer_id).to eq @w.id
    expect(@offer.status).to eq 'washer_accepted'

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @offer.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    @offer.reload
    expect(@offer.washer_id).to eq @w.id
    expect(json[:message]).to eq 'already_taken'
  end

  scenario 'washer has asap offers pending pickup but can still accept a scheduled pickup' do
    NewOrder.all.limit(@region.max_concurrent_offers - 1).each do |o|
      o.take_washer(@w)
    end

    @scheduled = NewOrder.last    
    @scheduled.update(pickup_type: 'scheduled')
    @scheduled.reload

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @scheduled.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'offer_accepted'

    # offer event
    expect(@w.offer_events.count).to eq 1
    expect(@scheduled.offer_events.count).to eq 1

    @event = @w.offer_events.last

    expect(@event.event_type).to eq 'offer_accepted'
    expect(@event.washer_id).to be_present
    expect(@event.new_order_id).to be_present
    expect(@event.feedback).to_not be_present
  end

  scenario 'washer is able to accept an offer' do
    @new_order = NewOrder.all.sample

    put '/api/v1/washers/offers/accept_offers', 
    params: {
      offer: {
        ref_code: @new_order.ref_code
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body).with_indifferent_access

    @new_order.reload
    # NEWORDER
    expect(@new_order.status).to eq 'washer_accepted'

    expect(json[:message]).to eq 'offer_accepted'
    # offer
    expect(@w.new_orders.last.status).to eq 'washer_accepted'
    @current_offer = json[:current_offer]

    expect(@current_offer[:ref_code]).to eq @new_order.ref_code
    expect(@current_offer[:return_by]).to be_present
    expect(@current_offer[:bags_to_scan]).to eq @new_order.bag_count
    expect(@current_offer[:pay]).to eq "$#{format('%.2f', @new_order.washer_pay)} + Tips"
    expect(@current_offer[:failed_pickup_fee]).to eq NewOrder.readable_decimal(@new_order.failed_pickup_fee)

    expect(@current_offer[:todo]).to eq @new_order.current_todo
    expect(@current_offer[:detergent]).to eq @new_order.readable_detergent
    expect(@current_offer[:softener]).to eq @new_order.readable_softener
    expect(@current_offer[:readable_return_by]).to eq "#{@new_order.est_delivery.strftime('%m/%d/%Y (by %I:%M%P)')}".titleize
    # current_step

    expect(@current_offer[:status]).to be_present
    expect(@current_offer[:status]).to eq @new_order.status

    # customer
    expect(@current_offer[:customer][:full_name]).to eq @new_order.user.full_name.upcase
    expect(@current_offer[:customer][:phone]).to eq @new_order.user.formatted_phone

    # address
    expect(@current_offer[:address][:address]).to eq @new_order.user.address.address
    expect(@current_offer[:address][:unit_number]).to eq @new_order.user.address.unit_number
    expect(@current_offer[:address][:lat]).to eq @new_order.user.address.latitude
    expect(@current_offer[:address][:lng]).to eq @new_order.user.address.longitude

    # offer event
    expect(@w.offer_events.count).to eq 1
    expect(@new_order.offer_events.count).to eq 1

    @event = @w.offer_events.last

    expect(@event.event_type).to eq 'offer_accepted'
    expect(@event.washer_id).to be_present
    expect(@event.new_order_id).to be_present
    expect(@event.feedback).to_not be_present
  end
end