require 'rails_helper'
require 'order_helper'
require 'offer_helper'
require 'stripe_helper'
RSpec.describe 'users/dashboards/new_order_flow/confirm_pickups_controller', type: :request do

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
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  # NEW START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    sign_out @user
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }
    expect(response).to redirect_to new_user_session_path
  end

  scenario 'user does not have an address' do
    # before_action :has_address?
    @user.address.destroy!
    @user.reload
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }
    expect(response).to redirect_to users_resolve_setups_path
  end

  scenario 'user has an address but its not within region' do
    # before_action :address_within_region?
    @user.address.update(region_id: nil)
    @user.reload
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }
    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end

  scenario 'user already has an order thats in progress' do
    # before_action :ensure_no_in_progress_orders
    @address.geocode
    @address.save
    create_open_offers(1)
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }
    expect(response).to redirect_to users_dashboards_homes_path
    expect(flash[:notice]).to eq 'You already have an order that is in progress.'
  end

  scenario 'order is valid' do
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    page = response.body

    expect(flash).to_not be_present
  end
  # NEW END

  # SUBSCRIPTION START (NOT YET IMPLEMENTED)
  # scenario 'user doesnt have an active subscription' do
  #   # before_action :has_active_subscription?
  #   @user.update(attributes_for(:user, :never_subscribed))
  #   @detergent = NewOrder::DETERGENTS.sample[:enum]
  #   @softener = NewOrder::SOFTENERS.sample[:enum]
  #   @bag_count = rand(1..10)

  #   get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
  #     new_order: {
  #       pickup_type: 'scheduled',
  #       detergent: @detergent,
  #       softener: @softener,
  #       bag_count: @bag_count
  #     }
  #   }
  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end

  # scenario 'users subscription is expired' do
  #   # before_action :has_active_subscription?
  #   @user.update(attributes_for(:user, :sub_expired))
  #   @detergent = NewOrder::DETERGENTS.sample[:enum]
  #   @softener = NewOrder::SOFTENERS.sample[:enum]
  #   @bag_count = rand(1..10)

  #   get new_users_dashboards_new_order_flow_scheduled_pickup_path, params: {
  #     new_order: {
  #       pickup_type: 'scheduled',
  #       detergent: @detergent,
  #       softener: @softener,
  #       bag_count: @bag_count
  #     }
  #   }
  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end
  # SUBSCRIPTION END
end