require 'rails_helper'
require 'order_helper'
require 'offer_helper'
RSpec.describe 'api/v1/users/dashboards/new_order_flow/refresh_wait_for_washers_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @region = create(:region, :open_washer_capacity)

    @user = create(:user, :with_active_subscription)
    @auth_token = JsonWebToken.encode(sub: @user.id)

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

  scenario 'the order is past the accept by time and the customer clicks continue waiting button and the accept by time is extended' do
    expect(@region.new_orders.offerable.count).to eq 1

    travel_to(DateTime.current + 66.minutes) do
      expect(@new_order.accept_by.future?).to eq false
      expect(@new_order.est_pickup_by.future?).to eq false
      expect(@region.new_orders.offerable.count).to eq 0

      put '/api/v1/users/dashboards/new_order_flow/refresh_wait_for_washers/1', 
      params: {
        new_order: {
          ref_code: @new_order.ref_code
        }
      },
      headers: {
        Authorization: @auth_token
      }
  
      json = JSON.parse(response.body)
  
      expect(json['message']).to eq 'offer_refreshed'
      # order
      @new_order.reload
      expect(@new_order.accept_by.future?).to eq true
      expect(@new_order.est_pickup_by.future?).to eq true
      # offer
      expect(@region.new_orders.offerable.count).to eq 1
    end
  end
end