# frozen_string_literal: true
require 'rails_helper'
require 'order_helper'

RSpec.describe 'generate delivery labels controller', type: :request do
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

    @order.mark_arrived_at_partner_for_pickup

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'views the generage labels form' do
		get new_workers_courier_tasks_pickup_from_partner_generate_delivery_labels_path(id: @order.id)
		
		@page = response.body

    expect(@page).to include('How Many Bags?')
	end
	
	scenario 'worker enters a bag count, the bag count is updated and labels are generated' do
		@bag_count = rand(1..100)

		post workers_courier_tasks_pickup_from_partner_generate_delivery_labels_path, params: {
			label: {
				id: @order.id,
				bag_count: @bag_count
			}
		}
		
		@page = response.body
		@order.reload

		expect(@page).to include(@user.formatted_name.upcase)
		expect(@page).to include(@order.bags_code)
		expect(@page).to include(@order.full_address.upcase)
		# order
		expect(@order.bags_collected).to eq @bag_count
	end
	
	scenario 'worker does not add a bag count and is kicked back' do
		@bag_count = rand(1..100)

		post workers_courier_tasks_pickup_from_partner_generate_delivery_labels_path, params: {
			label: {
				id: @order.id,
				bag_count: ''
			}
		}
		
		@page = response.body
		@order.reload

		expect(flash[:notice]).to eq 'You must enter a number of bags to continue.'

		expect(response).to redirect_to new_workers_courier_tasks_pickup_from_partner_generate_delivery_labels_path(id: @order.id)
  end
  
end
