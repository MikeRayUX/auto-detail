require 'rails_helper'
require 'order_helper'
require 'offer_helper'
require 'stripe_helper'

RSpec.describe 'users/dashboards/new_order_flow/asap_pickups_controller', type: :request do

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
  scenario 'user is not logged in' do
    ##before_action :authenticate_user!
    sign_out @user

    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)
    @pickup_type = 'scheduled'

    get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
      new_order: {
        pickup_type: @pickup_type,
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    expect(response).to redirect_to new_user_session_path
  end

  scenario 'user doesnt have an address' do
    ##before_action :has_address?
    @user.address.destroy!
    @user.reload

    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)
    @pickup_type = 'scheduled'

    get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
      new_order: {
        pickup_type: @pickup_type,
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    expect(response).to redirect_to users_resolve_setups_path
  end

  scenario 'user has an address but its not within a region (service area)' do
    ##before_action :address_within_region?
    @user.address.update(region_id: nil)
    # @user.reload

    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)
    @pickup_type = 'scheduled'

    get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
      new_order: {
        pickup_type: @pickup_type,
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end

  # scenario "user doesn't have an active subscription" do
  #   ##before_action :has_active_subscription?
  #   @address.geocode
  #   @address.save

  #   @user.update(attributes_for(:user, :never_subscribed))

  #   @detergent = NewOrder::DETERGENTS.sample[:enum]
  #   @softener = NewOrder::SOFTENERS.sample[:enum]
  #   @bag_count = rand(1..10)
  #   @pickup_type = 'scheduled'

  #   get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
  #     new_order: {
  #       pickup_type: @pickup_type,
  #       detergent: @detergent,
  #       softener: @softener,
  #       bag_count: @bag_count
  #     }
  #   }

  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end

  # scenario "users subscription has expired" do
  #   ##before_action :has_active_subscription?
  #   @address.geocode
  #   @address.save

  #   @user.update(attributes_for(:user, :sub_expired))

  #   @detergent = NewOrder::DETERGENTS.sample[:enum]
  #   @softener = NewOrder::SOFTENERS.sample[:enum]
  #   @bag_count = rand(1..10)
  #   @pickup_type = 'scheduled'

  #   get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
  #     new_order: {
  #       pickup_type: @pickup_type,
  #       detergent: @detergent,
  #       softener: @softener,
  #       bag_count: @bag_count
  #     }
  #   }

  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end

  scenario 'user already has an order in progress, so they are kicked back to dashboard home' do
    ## before_action :ensure_no_in_progress_orders
    @address.geocode
    @address.save
    create_open_offers(1)

    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)
    @pickup_type = 'scheduled'

    get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
      new_order: {
        pickup_type: @pickup_type,
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    expect(response).to redirect_to users_dashboards_homes_path
    expect(flash[:notice]).to eq 'You already have an order that is in progress.'
  end

  scenario 'order is invalid so user is kicked back to new page' do
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)
    @pickup_type = 'scheduled'

    get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
      new_order: {
        pickup_type: nil,
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    expect(response).to redirect_to new_users_dashboards_new_order_flow_pickups_path 
    expect(flash[:notice]).to be_present
  end

  scenario 'order is valid' do
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get new_users_dashboards_new_order_flow_asap_pickup_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    }

    expect(response).to have_http_status(:ok)
  end
  # NEW END

  # CREATE START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    sign_out @user

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    expect(response).to redirect_to new_user_session_path
  end

  scenario 'user doesnt have an address' do
    # before_action :has_address?
    @address.destroy!
    @user.reload

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    expect(response).to redirect_to users_resolve_setups_path
  end

  scenario 'user has an address but its not within region (service area)' do
    # before_action :address_within_region?
    @address.save
    @address.update(region_id: nil)

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    expect(response).to redirect_to users_dashboards_new_order_flow_outside_service_areas_path
  end

  # scenario 'user doesnt have an active subscription' do
  #   # before_action :has_active_subscription?
  #   @address.geocode
  #   @address.save

  #   @user.update(attributes_for(:user, :never_subscribed))

  #   @bag_count = rand(1..4)
  #   @tip = NewOrder::TIP_OPTIONS.sample

  #   post users_dashboards_new_order_flow_asap_pickups_path, params: {
  #     new_order: {
  #       pickup_type: 'asap',
  #       detergent: NewOrder.detergents.keys.sample,
  #       softener: NewOrder.softeners.keys.sample,
  #       bag_count: @bag_count,
  #       tip: @tip
  #     }
  #   }

  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end

  # scenario 'user subscription has expired' do
  #   # before_action :has_active_subscription?
  #   @address.geocode
  #   @address.save

  #   @user.update(attributes_for(:user, :sub_expired))

  #   @bag_count = rand(1..4)
  #   @tip = NewOrder::TIP_OPTIONS.sample

  #   post users_dashboards_new_order_flow_asap_pickups_path, params: {
  #     new_order: {
  #       pickup_type: 'asap',
  #       detergent: NewOrder.detergents.keys.sample,
  #       softener: NewOrder.softeners.keys.sample,
  #       bag_count: @bag_count,
  #       tip: @tip
  #     }
  #   }

  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end

  scenario 'user already has an order in progress, so they are kicked back to dashboard home' do
    # before_action :ensure_no_in_progress_orders
    create_stripe_customer!
    @address.geocode
    @address.save
    create_open_offers(1)

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    expect(response).to redirect_to users_dashboards_homes_path
    expect(flash[:notice]).to eq 'You already have an order that is in progress.'
  end

  scenario 'order is invalid' do
    create_stripe_customer!
    @address.geocode
    @address.save

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: '',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    @order = @user.new_orders.last

    expect(response).to redirect_to new_users_dashboards_new_order_flow_asap_pickup_path
  end

  scenario 'order is valid and card is added but the charge failed so the user is kicked back to new pickups page' do
    @stripe_token = new_stripe_token(CARD_WILL_FAIL)
    create_stripe_customer_from_token(@user, @stripe_token)

    @address.geocode
    @address.save

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    expect(response).to redirect_to new_users_dashboards_new_order_flow_pickups_path
    expect(flash[:notice]).to be_present

    # order
    expect(Order.count).to eq 0
  end

  scenario 'order is valid and is created/charged successfully as well as the customer has an active subscription and valid stripe id with successfull charge' do
    create_stripe_customer!
    @address.geocode
    @address.save

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    post users_dashboards_new_order_flow_asap_pickups_path, params: {
      new_order: {
        pickup_type: 'asap',
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    }

    @order = @user.new_orders.last

    expect(response).to redirect_to users_dashboards_new_order_flow_track_pickup_path(id: @order.ref_code)

    # order
    expect(@order.pickup_type).to eq 'asap'
    expect(@order.ref_code).to be_present
    expect(@order.detergent).to be_present
    expect(@order.softener).to be_present
    expect(@order.bag_count).to be_present
    expect(@order.pmt_processing_fee).to be_present
    expect(@order.failed_pickup_fee).to eq @region.failed_pickup_fee

    # pickup/delivery
    expect(@order.est_delivery).to be_present
    expect(@order.est_pickup_by).to be_present
    # offer
    expect(@order.accept_by).to be_present
    # address data
    expect(@order.directions).to eq @address.pick_up_directions
    expect(@order.address_lat).to eq @address.latitude
    expect(@order.address_lng).to eq @address.longitude
    # subtotal
    @subtotal = NewOrder.calc_subtotal(@bag_count, @region.price_per_bag)
    expect(@order.subtotal).to be_present
    expect(@order.subtotal).to eq @subtotal
    # tax
    @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate) 
    expect(@order.tax).to be_present
    expect(@order.tax).to eq @tax
    # tip
    expect(@order.tip).to be_present
    expect(@order.tip).to eq @tip
    # grandtotal
    @grandtotal = NewOrder.calc_grandtotal(
      @subtotal,
      @tax,
      @tip
    )
    expect(@order.grandtotal).to be_present
    expect(@order.grandtotal).to eq @grandtotal
    # washer ppb
    @washer_ppb = NewOrder.calc_washer_ppb(
      @subtotal, 
      @region.washer_pay_percentage, 
      @bag_count
    )
    expect(@order.washer_ppb).to be_present
    expect(@order.washer_ppb).to eq @washer_ppb.round(2)
    # washer pay
    @washer_pay = NewOrder.calc_washer_pay(
      @subtotal, 
      @region.washer_pay_percentage
    )

    expect(@order.washer_pay).to be_present
    expect(format('%.2f', @order.washer_pay)).to eq format('%.2f', @washer_pay)

    # washer final pay
    @washer_final_pay = NewOrder.calc_washer_final_pay(
      @subtotal, 
      @region.washer_pay_percentage, 
      @tip
    )
    expect(@order.washer_final_pay).to be_present
    expect(format('%.2f', @order.washer_final_pay)).to eq format('%.2f', @washer_final_pay)
    
    # payout desc
    @payout_desc = NewOrder.new_payout_desc(
      @tip, 
      @washer_final_pay
    )
    expect(@order.payout_desc).to be_present
    expect(@order.payout_desc).to eq @payout_desc
    # stripe charge
    expect(@order.stripe_charge_id).to be_present

    # EMAILS
    @email = ActionMailer::Base.deliveries.first
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(@email.to).to eq [@user.email]
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    expect(@email.subject).to eq 'Thank Your For Your Order | FreshAndTumble'
    # html 
    expect(@html_email).to include @order.bag_count
    expect(@html_email).to include format('%.2f', @order.subtotal)
    expect(@html_email).to include @region.tax_rate_percentage
    expect(@html_email).to include format('%.2f', @order.tax)
    expect(@html_email).to include format('%.2f', @order.tip)
    expect(@html_email).to include format('%.2f', @order.grandtotal)
    expect(@html_email).to include @user.readable_payment_method
    expect(@html_email).to include @address.full_address
    # text
    expect(@text_email).to include @order.bag_count
    expect(@text_email).to include format('%.2f', @order.subtotal)
    expect(@text_email).to include @region.tax_rate_percentage
    expect(@text_email).to include format('%.2f', @order.tax)
    expect(@text_email).to include format('%.2f', @order.tip)
    expect(@text_email).to include format('%.2f', @order.grandtotal)
    expect(@text_email).to include @user.readable_payment_method
    expect(@text_email).to include @address.full_address

    expect(@text_email).to_not include "Your Laundry is scheduled to be picked up"
    expect(@html_email).to_not include "Your Laundry is scheduled to be picked up"
  end
  # CREATE END
end