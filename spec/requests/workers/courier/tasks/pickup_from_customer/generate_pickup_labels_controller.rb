# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'workers/courier/pickup_from_customer/generate_pickup_labels_controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)
    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))
    @worker = create(:worker, :with_region)
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address
    ))

    @order.mark_arrived_for_pickup

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views the label creation form' do
		get new_workers_courier_tasks_pickup_from_customer_generate_pickup_labels_path(id: @order.id)

		expect(response.body).to match('How Many Bags?')
	end

	scenario 'worker creates new labels and the orders bags collected is updated as well as the bags code' do
		@bags_collected = rand(1..5)

		post workers_courier_tasks_pickup_from_customer_generate_pickup_labels_path, params: {
			label: {
				id: @order.id,
				bag_count: @bags_collected
			}
		}

		@page = response.body
		@order.reload

		# order
		expect(@order.bags_collected).to eq @bags_collected
		expect(@order.bags_code).to be_present
  end
end