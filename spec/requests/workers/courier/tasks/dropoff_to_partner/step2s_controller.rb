# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'drop off to customer step2s controller', type: :request do
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

    @order.mark_arrived_at_partner_for_dropoff

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views scan directions and codes to scan' do
    get workers_courier_tasks_dropoff_to_partner_step2_path(id: @order.id)

    expect(response.body).to include('Scan the correct code below')
    expect(response.body).to include(@order.bags_code)

    expect(response.body).to include("Bags: #{@order.bags_collected}")
    expect(response.body).to include("<span class='requiredCode text-3xl' marked-as-scanned='false'>#{@order.bags_code}</span>")
  end

  scenario 'worker enters valid bags code and proceeds to step3' do
    put workers_courier_tasks_dropoff_to_partner_step2_path, params: {
      id: @order.id,
      bags_code: @new_bags_code
    }

    expect(Order.first.drop_off_to_partner_status).to eq('scanned_existing_bags_for_order')
    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step3_path(id: @order.id)
  end

  scenario 'worker doesnt enter a code and is kicked back' do
    put workers_courier_tasks_dropoff_to_partner_step2_path, params: {
      id: @order.id,
      bags_code: ''
    }

    expect(Order.first.drop_off_to_partner_status).to eq('arrived_at_partner_for_dropoff')
    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step2_path(id: @order.id)
    expect(flash[:notice]).to eq('You must scan or enter bags code before continuing.')
  end

  scenario 'worker enteres an code that does not match order and is kicked back' do
    put workers_courier_tasks_dropoff_to_partner_step2_path, params: {
      id: @order.id,
      bags_code: get_new_bags_code
    }

    expect(Order.first.drop_off_to_partner_status).to eq('arrived_at_partner_for_dropoff')
    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step2_path(id: @order.id)
    expect(flash[:notice]).to eq('You must scan or enter bags code before continuing.')
  end
end
