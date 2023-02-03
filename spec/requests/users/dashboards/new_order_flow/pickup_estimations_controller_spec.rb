require 'rails_helper'
require 'order_helper'
RSpec.describe 'users/dashboards/new_order_flow/pickup_estimations_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(
      region_id: @region.id
    ))

    @user = create(:user)
    sign_in @user
    

    @address = @user.build_address(attributes_for(:address))
    @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach

    # the washer's address doesn't matter, if they are within region, they will be considered for an order within that region
    @w = Washer.create!(attributes_for(:washer, :activated).merge(region_id: @region.id))
    @w.create_address!(attributes_for(:address))
    @w.reload
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'business is current closed (too early)' do
    # before_action :business_open?
    travel_to(Time.parse(@region.business_open) - rand(1..20).minutes) do
      @region.refresh_last_washer_offer_check

      get '/users/dashboards/new_order_flow/pickup_estimations'
  
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'business_not_open'
      expect(json[:errors]).to eq "Asap is not currently available as it is past our normal business hours. You can still schedule a pickup for later or check back during normal business hours (#{@region.readable_business_hours})"
    end
  end

  scenario 'business is current closed (too late)' do
    # before_action :business_open?
    travel_to(Time.parse(@region.business_close) + rand(1..20).minutes) do
      @region.refresh_last_washer_offer_check

      get '/users/dashboards/new_order_flow/pickup_estimations'
  
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'business_not_open'
      expect(json[:errors]).to eq "Asap is not currently available as it is past our normal business hours. You can still schedule a pickup for later or check back during normal business hours (#{@region.readable_business_hours})"
    end
  end

  scenario "a washer hasn't checked for open offers within the last checked threshold so it is considered that no washers are online ans no_washers_available is returned" do
    # before_action :washers_available?
    travel_to( Time.parse(@region.business_open) + 1.minutes) do

      @region.update(last_washer_offer_check: DateTime.current - (Region::WASHERS_AVAILABLE_THRESHOLD + 1.minutes))

      get '/users/dashboards/new_order_flow/pickup_estimations'
      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'no_washers_available'
      expect(json[:pickup_estimate]).to_not be_present
    end
  end

  # scenario 'at least one washer has checked for open offers in the last minimum minutes so asap is available (washers_available)' do
  #   travel_to(Time.parse(@region.business_open) + 1.minutes) do
  #     @region.update(last_washer_offer_check: DateTime.current - (Region::WASHERS_AVAILABLE_THRESHOLD - 1.minutes))

  #     get '/users/dashboards/new_order_flow/pickup_estimations'

  #     json = JSON.parse(response.body).with_indifferent_access

  #     expect(json[:code]).to eq 200
  #     expect(json[:message]).to eq 'washers_available'
  #     expect(json[:pickup_estimate]).to be_present
  #   end
  # end

  scenario "open offers have never been check so last_washer_offer_check is nil and no_washers_available message is returned" do
    travel_to(Time.parse(@region.business_open) + 1.minutes) do

      get '/users/dashboards/new_order_flow/pickup_estimations'

      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'no_washers_available'
      expect(json[:pickup_estimate]).to_not be_present
    end
  end
end