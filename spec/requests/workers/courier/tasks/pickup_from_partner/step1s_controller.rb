# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'pickup from partner controller spec step1s', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    @region = create(:region)
    @pricing = create(:region_pricing)
    @user = create(:user, :with_payment_method)
    @address = @user.create_address!(attributes_for(:address))
    @worker = create(:worker, :with_region)
    @new_bags_code = get_new_bags_code
    @bags_collected = rand(1..5)

    @courier_weight = get_random_weight

    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address,
        bags_code: @new_bags_code,
        bags_collected: @bags_collected,
        courier_weight: @courier_weight
    ))

    @partner_location = @order.create_partner_location(attributes_for(:partner_location))

    @order.mark_received_by_partner

    mock_charged_order!

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views navigation information for picking up from partner' do
    get workers_courier_tasks_pickup_from_partner_step1_path(id: @order.id)

    expect(response.body).to include(@partner_location.business_name.upcase)
    expect(response.body).to include(@partner_location.street_address.upcase)
    expect(response.body).to include(@partner_location.city.upcase)
    expect(response.body).to include(@partner_location.state.upcase)
    expect(response.body).to include(@partner_location.zipcode.upcase)
  end

  scenario 'worker marks that they have arrived at partner location and moves on to step 2' do
    put workers_courier_tasks_pickup_from_partner_step1_path, params: {
      id: @order.id,
      unwashable_items: false
    }
   
    expect(response).to redirect_to workers_courier_tasks_pickup_from_partner_step2_path(id: @order.id)

    @order.reload

    expect(@order.pick_up_from_partner_status).to eq('arrived_at_partner_for_pickup')
    expect(@order.unwashable_items).to eq false
  end

  scenario 'worker marks that unwashable items are present in the order and the order attribute reflects that' do
    put workers_courier_tasks_pickup_from_partner_step1_path, params: {
      id: @order.id,
      unwashable_items: true
    }
   
    expect(response).to redirect_to workers_courier_tasks_pickup_from_partner_step2_path(id: @order.id)

    @order.reload

    expect(@order.pick_up_from_partner_status).to eq('arrived_at_partner_for_pickup')
    expect(@order.unwashable_items).to eq true
  end
end
