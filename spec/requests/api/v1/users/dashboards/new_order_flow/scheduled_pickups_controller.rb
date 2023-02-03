require 'rails_helper'
require 'order_helper'
require 'offer_helper'
require 'stripe_helper'
RSpec.describe 'api/v1/users/dashboards/new_order_flow/scheduled_pickups_controller', type: :request do

  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    @user = create(:user, :with_active_subscription)

    @region = create(:region)
    @coverage_area = CoverageArea.create!(attributes_for(:coverage_area).merge(
      region_id: @region.id
    ))

    @address = @user.build_address(attributes_for(:address))
    # @address.skip_geocode = true
    @address.save
    @address.attempt_region_attach

    @auth_token = JsonWebToken.encode(sub: @user.id)
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  # NEW START
  scenario 'user is not logged in' do
    # before_action :authenticate_user!
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', 
    params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    },
    headers: {
      Authorization: ''
    }


    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user does not have an address' do
    # before_action :has_address?
    @user.address.destroy!
    @user.reload
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', 
    params: {
        new_order: {
          pickup_type: 'scheduled',
          detergent: @detergent,
          softener: @softener,
          bag_count: @bag_count
        }
      },
      headers: {
        Authorization: @auth_token
      }

      json = JSON.parse(response.body).with_indifferent_access

      expect(json[:code]).to eq 3000
      expect(json[:message]).to eq 'setup_not_resolved'
  end

  scenario 'user has an address but its not within region' do
    # before_action :address_within_region?
    @user.address.update(region_id: nil)
    @user.reload
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', 
    params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    },
    headers: {
      Authorization: @auth_token
    }
    
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'outside_coverage_area'
  end

  scenario 'user already has an order thats in progress' do
    # before_action :ensure_no_in_progress_orders
    @address.geocode
    @address.save
    create_open_offers(1)
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', 
    params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_already_in_progress'
    expect(json[:errors]).to eq 'You already have an order that is in progress.'
  end

  scenario 'order is valid' do
    @detergent = NewOrder::DETERGENTS.sample[:enum]
    @softener = NewOrder::SOFTENERS.sample[:enum]
    @bag_count = rand(1..10)

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', 
    params: {
      new_order: {
        pickup_type: 'scheduled',
        detergent: @detergent,
        softener: @softener,
        bag_count: @bag_count,
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
      }
    },
    headers: {
        Authorization: @auth_token
      }
  
    json = JSON.parse(response.body).with_indifferent_access


    # response
    expect(json[:code]).to eq 200
    expect(json[:message]).to eq 'order_valid'
    # order
    expect(json[:confirmed_order][:bag_count]).to eq @bag_count
    @subtotal = NewOrder.calc_subtotal(@bag_count, @region.price_per_bag)
    expect(json[:confirmed_order][:subtotal]).to eq @subtotal.to_f.to_s
    expect(json[:confirmed_order][:tax_rate]).to eq @region.tax_rate
    expect(json[:confirmed_order][:readable_tax_rate]).to eq @region.tax_rate_percentage
    expect(json[:confirmed_order][:pickup_date]).to eq @pickup_date
    expect(json[:confirmed_order][:pickup_time]).to eq @pickup_time

    # est_delivery
    @formatted_pickup_date = ActiveSupport::TimeZone[Time.zone.name].parse("#{@pickup_date},#{@pickup_time}")
    @est_delivery = (@formatted_pickup_date + 24.hours).strftime('%m/%d/%Y (by 9pm)').titleize
    expect(json[:confirmed_order][:est_delivery]).to eq @est_delivery 
  end

  # SUBSCRIPTIONS (NOT ACTIVE)
  # scenario 'user doesnt have an active subscription' do
  #   ## before_action :has_active_subscription?
  #   @user.update(attributes_for(:user, :never_subscribed))
  #   @detergent = NewOrder::DETERGENTS.sample[:enum]
  #   @softener = NewOrder::SOFTENERS.sample[:enum]
  #   @bag_count = rand(1..10)

  #   get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', params: {
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
  #   ## before_action :has_active_subscription?
  #   @user.update(attributes_for(:user, :sub_expired))
  #   @detergent = NewOrder::DETERGENTS.sample[:enum]
  #   @softener = NewOrder::SOFTENERS.sample[:enum]
  #   @bag_count = rand(1..10)

  #   get '/api/v1/users/dashboards/new_order_flow/scheduled_pickups/new', params: {
  #     new_order: {
  #       pickup_type: 'scheduled',
  #       detergent: @detergent,
  #       softener: @softener,
  #       bag_count: @bag_count
  #     }
  #   }
  #   expect(response).to redirect_to users_resolve_subscriptions_path
  # end
  # NEW END

  # CREATE START
  scenario 'user is not logged in' do
    ## before_action :authenticate_user!
    @address.geocode
    @address.save
    sign_out @user

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
      new_order: {
        pickup_type: 'scheduled',
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      },
      headers: {
        Authorization: ''
      }
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'auth_error'
  end

  scenario 'user does not have an addresss' do
    ## before_action :has_address?
    @address.destroy!
    @user.reload

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
      new_order: {
        pickup_type: 'scheduled',
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'setup_not_resolved'
  end

  scenario 'user has an address but its not in region (service area)' do
    ## before_action :address_within_region?
    @address.geocode
    @address.save

    @address.update(region_id: nil)

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
      new_order: {
        pickup_type: 'scheduled',
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'outside_coverage_area'
  end

  ## scenario 'user does not have an active subscription' do
  ##   #### before_action :has_active_subscription?
  ##   ## @address.geocode
  ##   @address.save
  ##   @user.update(attributes_for(:user, :never_subscribed))

  ##   @bag_count = rand(1..4)
  ##   @tip = NewOrder::TIP_OPTIONS.sample

  ##   @days = rand(1..5).days
  ##   @pickup_date = (Date.current + @days).strftime
  ##   @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

  ##   post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
  ##     new_order: {
  ##       pickup_type: 'scheduled',
  ##       pickup_date: @pickup_date,
  ##       pickup_time: @pickup_time,
  ##       detergent: NewOrder.detergents.keys.sample,
  ##       softener: NewOrder.softeners.keys.sample,
  ##       bag_count: @bag_count,
  ##       tip: @tip
  ##     }
  ##   }

  ##   json = JSON.parse(response.body).with_indifferent_access

  ##   expect(json[:code]).to eq 3000
  ##   expect(json[:message]).to eq 'outside_coverage_area'
  ## end

  ## scenario 'users subscription is expired' do
  ##   #### before_action :has_active_subscription?
  ##   ## @address.geocode
  ##   @address.save
  ##   @user.update(attributes_for(:user, :sub_expired))

  ##   @bag_count = rand(1..4)
  ##   @tip = NewOrder::TIP_OPTIONS.sample

  ##   @days = rand(1..5).days
  ##   @pickup_date = (Date.current + @days).strftime
  ##   @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

  ##   post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
  ##     new_order: {
  ##       pickup_type: 'scheduled',
  ##       pickup_date: @pickup_date,
  ##       pickup_time: @pickup_time,
  ##       detergent: NewOrder.detergents.keys.sample,
  ##       softener: NewOrder.softeners.keys.sample,
  ##       bag_count: @bag_count,
  ##       tip: @tip
  ##     }
  ##   }

  ##   @order = @user.new_orders.last

  ##   expect(response).to redirect_to users_resolve_subscriptions_path
  ## end

  scenario 'user already has an active order' do
    ## before_action :ensure_no_in_progress_orders
    @address.geocode
    @address.save

    create_open_offers(1)

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
      new_order: {
        pickup_type: 'scheduled',
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_already_in_progress'
  end

  scenario 'order is valid but the card was declined so the customer is sent back to new pickup page and stripe error is displayed' do
    @stripe_token = new_stripe_token(CARD_WILL_FAIL)
    create_stripe_customer_from_token(@user, @stripe_token)
    
    @address.geocode
    @address.save

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
      new_order: {
        pickup_type: 'scheduled',
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    },
    headers: {
      Authorization: @auth_token
    }

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'stripe_error'
  end

  scenario 'order is valid scheduled so the accept_by time is set to the pickup_date/pickup_time' do
    create_stripe_customer!
    @address.geocode
    @address.save

    @bag_count = rand(1..4)
    @tip = NewOrder::TIP_OPTIONS.sample

    @days = rand(1..5).days
    @pickup_date = (Date.current + @days).strftime
    @pickup_time = Appointment::HOURLY_TIMESLOTS.sample

    post '/api/v1/users/dashboards/new_order_flow/scheduled_pickups', params: {
      new_order: {
        pickup_type: 'scheduled',
        pickup_date: @pickup_date,
        pickup_time: @pickup_time,
        detergent: NewOrder.detergents.keys.sample,
        softener: NewOrder.softeners.keys.sample,
        bag_count: @bag_count,
        tip: @tip
      }
    },
    headers: {
      Authorization: @auth_token
    }

    @order = @user.new_orders.last

    json = JSON.parse(response.body).with_indifferent_access

    # response
    expect(json[:code]).to eq 201
    expect(json[:message]).to eq 'order_created_successfully'
    expect(json[:ref_code]).to eq @order.ref_code
    # order
    expect(@order.pickup_type).to eq 'scheduled'
    expect(@order.ref_code).to be_present
    expect(@order.detergent).to be_present
    expect(@order.softener).to be_present
    expect(@order.bag_count).to be_present
    expect(@order.pmt_processing_fee).to be_present
    expect(@order.failed_pickup_fee).to eq @region.failed_pickup_fee
    # pickup/delivery
    expect(@order.est_delivery.to_date).to eq(Date.current + @days + 1.days)
    expect(@order.est_pickup_by.to_date).to eq(Date.current + @days)
    # offer
    expect(@order.accept_by.to_date).to eq(Date.current + @days)
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
    # scheduled pickup info
    expect(@text_email).to include "Your Laundry is scheduled to be picked up on #{@order.readable_scheduled}. You will receive an SMS notifcation when your Washer is on their way to you for pickup."
    expect(@html_email).to include "Your Laundry is scheduled to be picked up on #{@order.readable_scheduled}. You will receive an SMS notifcation when your Washer is on their way to you for pickup."
    # text
    expect(@text_email).to include @order.bag_count
    expect(@text_email).to include format('%.2f', @order.subtotal)
    expect(@text_email).to include @region.tax_rate_percentage
    expect(@text_email).to include format('%.2f', @order.tax)
    expect(@text_email).to include format('%.2f', @order.tip)
    expect(@text_email).to include format('%.2f', @order.grandtotal)
    expect(@text_email).to include @user.readable_payment_method
    expect(@text_email).to include @address.full_address
  end
  # # CREATE END
end