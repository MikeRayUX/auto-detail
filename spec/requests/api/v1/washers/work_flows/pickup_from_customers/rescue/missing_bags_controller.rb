require 'rails_helper'
require 'offer_helper'
require 'order_helper'
RSpec.describe 'api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags_controller', type: :request do
  include ActiveSupport::Testing::TimeHelpers
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear

    setup_payoutable_washer_spec
    create_open_offers(1)
    
    @new_order.take_washer(@w)
    @new_order.mark_arrived_for_pickup
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
  end

  scenario 'washer is not logged in' do
    # before_action :authenticate_washer!
    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', {
      headers: {
        Authorization: ''
      }
    }
    json = JSON.parse(response.body)
    expect(json['status']).to eq 'unauthorized'
  end

  scenario 'invalid order ref_code' do
    # before_action :ensure_order_exists
    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', {
    params: { 
      new_order: {
        ref_code: 'asdfafsd'
      },
    },
      headers: {
        Authorization: @auth
      }
    }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_not_found'
  end

  scenario 'washer no longer has connection to order for whatever reason' do
    # before_action :ensure_order_exists
    @new_order.drop_washer

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', {
    params: { 
      new_order: {
        ref_code: @new_order.ref_code
      },
    },
      headers: {
        Authorization: @auth
      }
    }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'order_not_found'
  end

  scenario 'washer attempts to update the bag count while the order is in the wrong status ' do
    # before_action :ensure_status
    @new_order.mark_enroute_for_pickup


    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', 
      params: { 
        new_order: {
          ref_code: @new_order.ref_code
        }
      },
      headers: {
        Authorization: @auth
      }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'invalid_order_status'
  end 

  scenario 'washer tries to pass a bag_count value that is 0' do
    # before_action :bag_count_adjustable?
    @new_order.mark_arrived_for_pickup


    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', 
      params: { 
        new_order: {
          ref_code: @new_order.ref_code,
          missing_bags_count: 0
        }
      },
      headers: {
        Authorization: @auth
      }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'not_adjustable'
  end 

  scenario 'washer tries to pass a bag_count value that is equal to orders bag count making an adjustment pointless' do
    # before_action :bag_count_adjustable?
    @new_order.mark_arrived_for_pickup

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', 
      params: { 
        new_order: {
          ref_code: @new_order.ref_code,
          missing_bags_count: @new_order.bag_count
        }
      },
      headers: {
        Authorization: @auth
      }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'not_adjustable'
  end 

  scenario 'washer tries to pass a bag_count value that is higher than the orders bag_count' do
    # before_action :bag_count_adjustable?
    @new_order.mark_arrived_for_pickup

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', 
      params: { 
        new_order: {
          ref_code: @new_order.ref_code,
          missing_bags_count: @new_order.bag_count + 1
        }
      },
      headers: {
        Authorization: @auth
      }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'not_adjustable'
  end 

  scenario 'washer already adjusted bag count once tries to adjust it again and gets kicked back' do
    # before_action :already_adjusted?
    @new_order.mark_arrived_for_pickup

    @old_bag_count = @new_order.bag_count
    @missing_bags_count = rand(1..(@old_bag_count))

    if @missing_bags_count == @new_order.bag_count
      @missing_bags_count = (@new_order.bag_count - 1)
    end

    @new_bag_count =  @old_bag_count - @missing_bags_count
    @new_order.washer_adjust_bag_count(@new_bag_count)

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', 
      params: { 
        new_order: {
          ref_code: @new_order.ref_code,
          missing_bags_count: @missing_bags_count
        }
      },
      headers: {
        Authorization: @auth
      }
    json = JSON.parse(response.body).with_indifferent_access

    expect(json[:code]).to eq 3000
    expect(json[:message]).to eq 'already_adjusted'
  end 

  scenario 'washer indicates that one or more bags are missing, the bag count is not 0 or higher than original count, the bag count is adjusted, the customer is sent a notification email, and the current_offer is returned' do
    @new_order.mark_arrived_for_pickup
    @new_order.reload

    @old_bag_count = @new_order.bag_count
    @missing_bags_count = rand(1..(@old_bag_count))

    if @missing_bags_count == @new_order.bag_count
      @missing_bags_count = (@new_order.bag_count - 1)
    end

    @new_bag_count =  @old_bag_count - @missing_bags_count

    put '/api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags', 
    params: { 
      new_order: {
        ref_code: @new_order.ref_code,
        missing_bags_count: @missing_bags_count
      }
    },
      headers: {
        Authorization: @auth
      }

    json = JSON.parse(response.body).with_indifferent_access
    @new_order.reload

    expect(json[:code]).to eq 204
    expect(json[:message]).to eq 'bag_count_adjusted_successfully'

    # current_offer
    @current_offer = json[:current_offer]
    expect(@current_offer[:ref_code]).to eq @new_order.ref_code
    expect(@current_offer[:bags_to_scan]).to eq @new_order.bag_count
    expect(@current_offer[:bags_to_scan]).to eq @new_bag_count
    expect(@current_offer[:failed_pickup_fee]).to eq NewOrder.readable_decimal(@new_order.failed_pickup_fee)

    # order
    expect(@new_order.bag_count).to eq @old_bag_count - @missing_bags_count
    expect(@new_order.washer_adjusted_bag_count_at > 10.seconds.ago).to eq true

    # # offer_event
    @offer_event = OfferEvent.first
    expect(@offer_event.washer_id).to eq @w.id
    expect(@offer_event.new_order_id).to eq @new_order.id
    expect(@offer_event.event_type).to eq 'bags_missing_pickup'
    expect(@offer_event.feedback).to eq "WAS (#{@old_bag_count}), IS NOW (#{@new_bag_count})"
    
    # email
    expect(ActionMailer::Base.deliveries.count).to eq 1
    @email = ActionMailer::Base.deliveries.last
    @html_email = @email.html_part.body
    @text_email = @email.text_part.body
    expect(@email.to).to eq [@user.email]
    expect(@email.subject).to eq 'Uh oh! There was a issue with your order | FreshAndTumble'
    expect(@email.from).to eq ['no-reply@freshandtumble.com']
    # html_email
    expect(@html_email).to include 'Our Washer indicated that one or more bags were missing from your order while attempting to pickup your laundry.'
    expect(@html_email).to include @user.first_name
    expect(@html_email).to include "Bags Our Washer Attempted To Pickup: #{@old_bag_count}"
    expect(@html_email).to include "Bags Missing: #{@missing_bags_count}"
    expect(@html_email).to include "Bags Picked Up: #{@new_order_bag_count}"
    # text_email
    expect(@html_email).to include 'Our Washer indicated that one or more bags were missing from your order while attempting to pickup your laundry.'
    expect(@text_email).to include @user.first_name
    expect(@text_email).to include "Bags Our Washer Attempted To Pickup: #{@old_bag_count}"
    expect(@text_email).to include "Bags Missing: #{@missing_bags_count}"
    expect(@text_email).to include "Bags Picked Up: #{@new_order_bag_count}"
  end
end