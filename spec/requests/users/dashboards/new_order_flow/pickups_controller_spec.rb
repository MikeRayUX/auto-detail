require 'rails_helper'
require 'order_helper'
require 'offer_helper'
RSpec.describe 'users/dashboards/new_order_flow/pickups_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @user = create(:user, :with_active_subscription)
    sign_in @user

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(
      region_id: @region.id
    ))

    @address = @user.build_address(attributes_for(:address))
    @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach


    # the washer's address doesn't matter, if they are within region, they will be considered for an order within that region
    @w = Washer.create!(attributes_for(:washer, :online).merge(region_id: @region.id))
    @w.create_address!(attributes_for(:address))
    @w.reload
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  # NEW START
  # before_action :authenticate_user!
  scenario 'user is not logged in' do
    sign_out @user
   
    get new_users_dashboards_new_order_flow_pickups_path

    expect(response).to redirect_to new_user_session_path
  end
  
  # before_action :ensure_no_in_progress_orders
  scenario 'user already has an order in progress, so they are kicked back to dashboard home' do
    @address.geocode
    @address.save
    create_open_offers(1)

    get new_users_dashboards_new_order_flow_pickups_path

    expect(response).to redirect_to users_dashboards_homes_path
    expect(flash[:notice]).to eq 'You already have an order that is in progress.'
  end

  # before_action :has_address?
  scenario 'user does not have an address (completed setup) so they are directed to outside service areas page' do
    @user.address.destroy!
    @user.reload

    get new_users_dashboards_new_order_flow_pickups_path

    expect(response).to redirect_to users_resolve_setups_path
  end

  # before_action :address_within_region?
  scenario 'user has an address but that address does not have a region (outside service area) so they are redirected to outside service areas page' do
    @user.address.update(region_id: nil)
    @user.reload

    get new_users_dashboards_new_order_flow_pickups_path

    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end

  # scenario 'user has an address within region but no active subscription, so they are redirected to resolve subscriptions' do
  #   # before_action :has_active_subscription?
  #   @user.update(attributes_for(:user, :never_subscribed))

  #   get new_users_dashboards_new_order_flow_pickups_path

  #   page = response.body

  #   expect(response).to_not redirect_to new_users_resolve_subscription_path
  # end

  scenario 'user has both an address, and that address is within region, so they are able to visit the new orders page and view the order form' do
    get new_users_dashboards_new_order_flow_pickups_path

    page = response.body

    expect(response).to_not redirect_to users_outside_coverage_areas_path
  end

  # scenario 'user has an active subscription so they are allowed to start an order' do
  #   get new_users_dashboards_new_order_flow_pickups_path

  #   page = response.body

  #   expect(response).to_not redirect_to users_outside_coverage_areas_path
  # end

  # scenario 'user subscription is inactive so they are redirected to resolve subscriptions' do
  #   @user.update(attributes_for(:user, :never_subscribed))
  #   get new_users_dashboards_new_order_flow_pickups_path

  #   page = response.body

  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end
  # NEW END
end