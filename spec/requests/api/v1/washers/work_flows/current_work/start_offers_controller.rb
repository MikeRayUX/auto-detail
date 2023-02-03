require 'rails_helper'
require 'offer_helper'
RSpec.describe 'api/v1/washers/workflows/current_work/start_offers_controller', type: :request do
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

  # GET START
  scenario 'washer is not activated' do
    # before_action :washer_activated?
    @w.update(attributes_for(:washer, :deactivated))

    get '/api/v1/washers/work_flows/current_work/start_offers', params: {
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

  scenario 'offer doesnt exist' do
    # before_action :before_action :offer_exists?
    @offer.update(
      washer_id: nil
    )

    get '/api/v1/washers/work_flows/current_work/start_offers', params: {
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

   scenario 'washer accepted an offer and is taken to the resume offers screen, a status is returned and what screen the washer is navigated to inside the app is handled on the app end' do
      get '/api/v1/washers/work_flows/current_work/start_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      }

      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:pickup_type]).to eq @offer.pickup_type
      expect(json[:message]).to eq 'status_returned'
      expect(json[:status]).to eq @offer.status
   end

  # GET END

  # PUT START
  scenario 'washer is not activated' do
    # before_action :washer_activated
    @w.update(attributes_for(:washer, :deactivated))
    put '/api/v1/washers/work_flows/current_work/start_offers', params: {
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

  scenario 'offer not found / washer was dropped from offer and an error is returned' do
    # before_action :offer_exists?
    @offer.update(
      washer_id: nil
    )

    put '/api/v1/washers/work_flows/current_work/start_offers', params: {
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

  scenario 'washer tries to start scheduled order pickup too early' do
    # before_action :too_early?
    travel_to(@pickup_date - (NewOrder::START_LIMIT + 1).minutes) do

      put '/api/v1/washers/work_flows/current_work/start_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      } 
      
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'too_early'
    end
  end

  scenario 'washer tries to start scheduled order pickup too late' do
    # before_action :too_late?
    travel_to(@pickup_date + 1.minutes) do

      put '/api/v1/washers/work_flows/current_work/start_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      } 
      
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'too_late'
    end
  end

  scenario 'order is cancelled so an order_cancelled error is returned' do
    # before_action :not_cancelled?
    travel_to(@pickup_date - 1.minutes) do
      @offer.soft_cancel

      put '/api/v1/washers/work_flows/current_work/start_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      } 
      
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'order_cancelled'
    end
  end

  scenario 'washer is able to start scheduled offer because it is less than 45 mins from appointment time' do
    travel_to(@pickup_date - 44.minutes) do

      put '/api/v1/washers/work_flows/current_work/start_offers', params: {
        offer: {
          ref_code: @offer.ref_code
        }
      },
      headers: {
        Authorization: @auth
      } 
      
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:message]).to eq 'pickup_started'

      # notification
      expect(@offer.user.notifications.count).to eq 1
      expect(@offer.notifications.count).to eq 1
      @notification = @offer.notifications.first
      expect(@notification.new_order_id).to eq @offer.id
      expect(@notification.notification_method).to eq 'sms'
      expect(@notification.event).to eq 'enroute_to_customer_for_pickup'
    end
  end
  # PUT END
end