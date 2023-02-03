require 'rails_helper'
require 'offer_helper'
require 'order_helper'
RSpec.describe 'api/v1/washers/work_flows/deliver_to_customers/deliveries_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    setup_activated_washer_spec
    create_open_offers(1)

    @new_order.take_washer(@w)
    @new_order.mark_arrived_for_pickup
    @codes_params = []
    @new_order.bag_count.times do
      @codes_params.push(SecureRandom.hex(2).upcase)
    end
    @new_order.mark_picked_up(@codes_params.to_json)
    @new_order.mark_completed
    
    # SAMPLE_DELIVERY_PHOTO_BASE64
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'auth check' do
    # before_action :authenticate_washer!
    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
      headers: {
        Authorization: ''
      }
    
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'ensure_current_location check' do
    # before_action :ensure_current_location

    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
    params: {
      new_order: {
        ref_code: ''
      },
      current_location: {
        lat: '',
        lng: ''
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body)
    expect(json['message']).to eq 'location_required'
  end

  scenario 'ensure_order_exists check' do
    # before_action :ensure_order_exists
    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
    params: {
      new_order: {
        ref_code: ''
      },
      current_location: {
        lat: 12.65,
        lng: -12.5687
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body)
    expect(json['message']).to eq 'order_not_found'
  end

  scenario 'ensure_status check' do
    # before_action :ensure_status

    @new_order.mark_enroute_for_pickup
    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code
      },
      current_location: {
        lat: 12332.3212,
        lng: -1234.234
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body)
    expect(json['message']).to eq 'already_delivered'
  end

  # THIS FEATURE IS CURRENTLY DISABLED RETURNING TRUE IN THE METHOD (FOR IRL TESTING PURPOSES)
  # scenario 'washer is not close enough so a not_close_enough error is returned' do
  #   @delivery_location = NewOrder.delivery_locations.to_a.sample.first
  #   put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
  #   params: {
  #     new_order: {
  #       ref_code: @new_order.ref_code,
  #       delivery_location: @delivery_location,
  #       delivery_photo_base64: SAMPLE_DELIVERY_PHOTO_BASE64
  #     },
  #     current_location: {
  #       lat: 12332.3212,
  #       lng: -1234.234
  #     }
  #   },
  #   headers: {
  #     Authorization: @auth
  #   }
    
  #   json = JSON.parse(response.body)
  #   expect(json['message']).to eq 'not_close_enough'
  # end

  scenario 'order is delivered successfully (washer is in range), the customer is notified via sms and email as well as a payment (stripe transfer) is created for the washer' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)
    @w.update(attributes_for(:washer, :payoutable))

    @delivery_location = NewOrder.delivery_locations.to_a.sample.first

    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code,
        delivery_location: @delivery_location,
        delivery_photo_base64: SAMPLE_DELIVERY_PHOTO_BASE64
      },
      current_location: {
        lat: @new_order.address_lat,
        lng: @new_order.address_lng
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body)
    expect(json['code']).to eq 204
    expect(json['message']).to eq 'delivery_completed'

    # ORDER
    @new_order.reload
    expect(@new_order.delivered_at).to be_present
    expect(@new_order.readable_delivered_at).to be_present
    expect(@new_order.status).to eq 'delivered'
    expect(@new_order.payout_desc).to be_present
    expect(@new_order.delivery_location).to eq @delivery_location
    expect(@new_order.delivery_photo_base64).to be_present
    expect(@new_order.delivery_photo_base64).to eq SAMPLE_DELIVERY_PHOTO_BASE64

    # STRIPE
    expect(@new_order.stripe_transfer_id).to be_present
    expect(@new_order.stripe_charge_id).to be_present
    expect(@new_order.stripe_transfer_error).to_not be_present
    # USER
    @user.reload
    expect(@user.notifications.count).to eq 1
    # NOTIFICATION
    @n = @user.notifications.first
    expect(@n.new_order_id).to eq @new_order.id
    expect(@n.notification_method).to eq 'sms'
    expect(@n.event).to eq 'order_delivered'
    expect(@n.message_body).to eq "#{@w.abbrev_name} just delivered your FreshAndTumble.com laundry order. So fresh and clean!"

    # offer_event
    @event = @new_order.offer_events.last
    expect(@event.washer_id).to eq @w.id
    expect(@event.new_order_id).to eq @new_order.id
    expect(@event.event_type).to eq 'delivered'

    # email
    @email = ActionMailer::Base.deliveries.first
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.subject).to eq 'Your Laundry Was Delivered!'
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    # html_email
    expect(@html_email).to include "Your FreshAndTumble Laundry Order has been delivered! Enjoy your fresh clothes!"
    expect(@html_email).to include @user.first_name
    expect(@html_email).to include @new_order.readable_delivered
    expect(@html_email).to include @new_order.readable_delivery_location
    # text_email
    expect(@text_email).to include "Your FreshAndTumble Laundry Order has been delivered! Enjoy your fresh clothes!"
    expect(@text_email).to include @user.first_name
    expect(@text_email).to include @new_order.readable_delivered
    expect(@text_email).to include @new_order.readable_delivery_location
  end

  scenario 'order is delivered early and the offer event shows the minutes early' do
    travel_to(@new_order.est_delivery - 5.minutes) do
      create_stripe_customer!
      charge_new_order!(@user, @new_order)
      @w.update(attributes_for(:washer, :payoutable))
  
      @delivery_location = NewOrder.delivery_locations.to_a.sample.first
  
      put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
      params: {
        new_order: {
          ref_code: @new_order.ref_code,
          delivery_location: @delivery_location,
          delivery_photo_base64: SAMPLE_DELIVERY_PHOTO_BASE64
        },
        current_location: {
          lat: @new_order.address_lat,
          lng: @new_order.address_lng
        }
      },
      headers: {
        Authorization: @auth
      }

      @new_order.reload
      
      json = JSON.parse(response.body)
      expect(json['code']).to eq 204
      expect(json['message']).to eq 'delivery_completed'
  
      # offer_event
      @event = @new_order.offer_events.last
      expect(@event.washer_id).to eq @w.id
      expect(@event.new_order_id).to eq @new_order.id
      expect(@event.event_type).to eq 'delivered'
      
      expect(@event.feedback).to eq "#{@new_order.readable_delivery_location} (5 MINUTES EARLY)"
    end
  end

  scenario 'order is delivered late and the offer event shows the minutes late' do
    travel_to(@new_order.est_delivery + 5.minutes) do
      create_stripe_customer!
      charge_new_order!(@user, @new_order)
      @w.update(attributes_for(:washer, :payoutable))
  
      @delivery_location = NewOrder.delivery_locations.to_a.sample.first
  
      put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
      params: {
        new_order: {
          ref_code: @new_order.ref_code,
          delivery_location: @delivery_location,
          delivery_photo_base64: SAMPLE_DELIVERY_PHOTO_BASE64
        },
        current_location: {
          lat: @new_order.address_lat,
          lng: @new_order.address_lng
        }
      },
      headers: {
        Authorization: @auth
      }

      @new_order.reload
      
      json = JSON.parse(response.body)
      expect(json['code']).to eq 204
      expect(json['message']).to eq 'delivery_completed'
  
      # offer_event
      @event = @new_order.offer_events.last
      expect(@event.washer_id).to eq @w.id
      expect(@event.new_order_id).to eq @new_order.id
      expect(@event.event_type).to eq 'delivered'
      
      expect(@event.feedback).to eq "#{@new_order.readable_delivery_location} (4 MINUTES LATE)"
    end
  end

  scenario 'washer is an employee and therefore not payoutable as an independent contractor with stripe connect so no transfer is made' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)
    @w.update(attributes_for(:washer, :payoutable))
    @w.update(payoutable_as_ic: false);

    @delivery_location = NewOrder.delivery_locations.to_a.sample.first

    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code,
        delivery_location: @delivery_location,
        delivery_photo_base64: SAMPLE_DELIVERY_PHOTO_BASE64
      },
      current_location: {
        lat: @new_order.address_lat,
        lng: @new_order.address_lng
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body)
    expect(json['code']).to eq 204
    expect(json['message']).to eq 'delivery_completed'

    # ORDER
    @new_order.reload
    expect(@new_order.delivered_at).to be_present
    expect(@new_order.readable_delivered_at).to be_present
    expect(@new_order.status).to eq 'delivered'
    expect(@new_order.payout_desc).to be_present
    # STRIPE
    expect(@new_order.stripe_transfer_id).to eq nil
    expect(@new_order.stripe_transfer_error).to eq nil
    # USER
    @user.reload
    expect(@user.notifications.count).to eq 1
    # NOTIFICATION
    @n = @user.notifications.first
    expect(@n.new_order_id).to eq @new_order.id
    expect(@n.notification_method).to eq 'sms'
    expect(@n.event).to eq 'order_delivered'
    expect(@n.message_body).to eq "#{@w.abbrev_name} just delivered your FreshAndTumble.com laundry order. So fresh and clean!"
  end

  scenario 'there was an error in the stripe tranfser and its error is stored on the new order stripe_tranfer_error attribute, but the delivery is allowed to complete anyway' do
    create_stripe_customer!
    charge_new_order!(@user, @new_order)
    @w.create_stripe_account!
    
    @delivery_location = NewOrder.delivery_locations.to_a.sample.first

    put '/api/v1/washers/work_flows/deliver_to_customers/deliveries', 
    params: {
      new_order: {
        ref_code: @new_order.ref_code,
        delivery_location: @delivery_location,
        delivery_photo_base64: SAMPLE_DELIVERY_PHOTO_BASE64
      },
      current_location: {
        lat: @new_order.address_lat,
        lng: @new_order.address_lng
      }
    },
    headers: {
      Authorization: @auth
    }
    
    json = JSON.parse(response.body)

    expect(json['code']).to eq 204
    expect(json['message']).to eq 'delivery_completed'

    # ORDER
    @new_order.reload
    expect(@new_order.delivered_at).to be_present
    expect(@new_order.readable_delivered_at).to be_present
    expect(@new_order.status).to eq 'delivered'
    expect(@new_order.payout_desc).to be_present
    p @new_order.payout_desc
    # STRIPE
    expect(@new_order.stripe_transfer_id).to_not be_present
    expect(@new_order.stripe_charge_id).to be_present
    expect(@new_order.stripe_transfer_error).to be_present
    # USER
    @user.reload
    expect(@user.notifications.count).to eq 1
    # NOTIFICATION
    @n = @user.notifications.first
    expect(@n.new_order_id).to eq @new_order.id
    expect(@n.notification_method).to eq 'sms'
    expect(@n.event).to eq 'order_delivered'
    expect(@n.message_body).to eq "#{@w.abbrev_name} just delivered your FreshAndTumble.com laundry order. So fresh and clean!"
  end
end

