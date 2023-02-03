# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'deliver to customer controller step2s', type: :request do
  before do
		DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)
    @user = create(:user)
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

    @random_invoice_number = get_new_bags_code

    @order.mark_picked_up_from_partner

    @order.mark_arrived_at_customer_for_delivery

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views the scan form of step 2' do
		get workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
		
		@page = response.body

    expect(@page).to include(@order.bags_code)
		expect(@page).to include('Scan the correct code below')
  end

  scenario 'worker scans valid code and moves on to the next step' do
    put workers_courier_tasks_deliver_to_customer_step2_path, params: {
      id: @order.id,
      bags_code: @order.bags_code
    }

    expect(Order.first.deliver_to_customer_status).to eq('scanned_existing_bags_for_delivery')
    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step3_path(id: @order.id)
  end

  scenario 'worker encounteres an issue scanning the bags and manually enters a valid code' do
    put workers_courier_tasks_deliver_to_customer_step2_path, params: {
      id: @order.id,
      manually_entered_code: @order.bags_code
    }

    expect(Order.first.deliver_to_customer_status).to eq('scanned_existing_bags_for_delivery')
    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step3_path(id: @order.id)
  end

  scenario 'worker enters an invalid code and is kicked back to the scan code page' do
    put workers_courier_tasks_deliver_to_customer_step2_path, params: {
      id: @order.id,
      bags_code: 'iadsjf0aisjdfoij'
    }

    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
    expect(flash[:notice]).to eq('You must scan the correct code.')
  end

  scenario 'worker does not enter a code at all and is kicked back' do
    put workers_courier_tasks_deliver_to_customer_step2_path, params: {
      id: @order.id,
      bags_code: ''
    }

    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
    expect(flash[:notice]).to eq('You must scan the correct code.')
  end

  scenario 'worker enteres an invalid manually entered code and is kicked back' do
    put workers_courier_tasks_deliver_to_customer_step2_path, params: {
      id: @order.id,
      manually_entered_code: '02398o0eijfsdoifj'
    }

    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
    expect(flash[:notice]).to eq('You must scan the correct code.')
  end

  scenario 'worker enters both an invalid scanned code and manually entered code' do
    put workers_courier_tasks_deliver_to_customer_step2_path, params: {
      id: @order.id,
      bags_code: 'aosdijfaosidj098uj',
      manually_entered_code: '02398o0eijfsdoifj'
    }

    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
    expect(flash[:notice]).to eq('You must scan the correct code.')
  end
end
