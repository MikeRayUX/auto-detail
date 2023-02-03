# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'pickup from partner controller spec step3s', type: :request do
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

    @order.mark_acknowledged_partner_pickup_directions

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views pickup from partner scan existing bags scan form' do
    get workers_courier_tasks_pickup_from_partner_step3_path(id: @order.id)

    page = response.body

    expect(page).to include("Bags: (about #{@order.bags_collected})")
    expect(page).to include("<span class='requiredCode text-3xl' marked-as-scanned='false'>#{@order.bags_code}</span>")
  end

	scenario 'worker uses scan code form and submits valid codes and the order is marked as picked_up_from_partner' do
    put workers_courier_tasks_pickup_from_partner_step3_path, params: {
      id: @order.id,
			bags_code: @order.bags_code
		}
		
    @order.reload
    
    expect(response).to redirect_to workers_dashboards_processing_orders_path
    expect(flash[:notice]).to eq 'Pickup from partner completed.'
		expect(@order.pick_up_from_partner_status).to eq('picked_up_from_partner')
		expect(@order.bags_collected).to eq @bags_collected
  end
  
  scenario 'worker enters the wrong code and is kicked back' do
    put workers_courier_tasks_pickup_from_partner_step3_path, params: {
      id: @order.id,
			bags_code: 'asdfasdf'
		}
		
    @order.reload
    
    expect(response).to redirect_to workers_courier_tasks_pickup_from_partner_step3_path(id: @order.id)
    expect(flash[:notice]).to eq 'You must scan all codes listed.'
		expect(@order.pick_up_from_partner_status).to eq('acknowledged_partner_pickup_directions')
	end
end