# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'drop off to customer step3s controller', type: :request do
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

    @order.mark_scanned_for_partner_dropoff

    mock_charged_order!

    sign_in @worker
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    sign_out @worker
  end

  scenario 'worker views the enter partner reported weight' do
    get workers_courier_tasks_dropoff_to_partner_step3_path(id: @order.id)

    @page = response.body

    expect(@page).to include(@order.bags_code)
    expect(@page).to include(@order.readable_weight)
  end

  scenario 'worker enters valid weight and moves on to step 4' do
    @partner_weight = rand(10.00..50.00).round(2)
    
    put workers_courier_tasks_dropoff_to_partner_step3_path, params: {
      id: @order.id,
      weight: @partner_weight
    }

    @order.reload

    expect(@order.drop_off_to_partner_status).to eq('recorded_partner_weight')
    expect(@order.partner_reported_weight).to eq @partner_weight
    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step4_path(id: @order.id)
  end

  scenario 'worker does not enter a weight and is kickec back' do
    @partner_weight = nil
    
    put workers_courier_tasks_dropoff_to_partner_step3_path, params: {
      id: @order.id,
      weight: @partner_weight
    }

    @order.reload

    expect(flash[:notice]).to eq 'You must enter a valid weight to continue.'
    expect(@order.drop_off_to_partner_status).to eq('scanned_existing_bags_for_order')
    expect(@order.partner_reported_weight).to eq @partner_weight
    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step3_path(id: @order.id)
  end

  scenario 'worker does not enter valid weight datatype and is kickec back' do
    @partner_weight = 'asdf'
    
    put workers_courier_tasks_dropoff_to_partner_step3_path, params: {
      id: @order.id,
      weight: @partner_weight
    }

    @order.reload

    expect(flash[:notice]).to eq 'You must enter a valid weight to continue.'
    expect(@order.drop_off_to_partner_status).to eq('scanned_existing_bags_for_order')
    expect(@order.partner_reported_weight).to eq nil
    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step3_path(id: @order.id)
  end
end
