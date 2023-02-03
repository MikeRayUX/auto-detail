# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'pickup from customer step2s controller spec', type: :request do
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

  scenario 'worker has marked themselves as arrived at customer addres and is given instructions on how to proceed' do
    get workers_courier_tasks_pickup_from_customer_step2_path, params: {
      id: @order.id
    }

    @page = response.body

    expect(@page).to include(@address.readable_pickup_directions)
		expect(@page).to include("Locate Customer Order")
		expect(@page).to include("Print labels")
		expect(@page).to include("Attach labels and continue")
	end
	
	scenario 'worker prints labels and is able to continue to step3' do
		@new_code = get_new_bags_code
		@bags_collected = rand(1..5)

		@order.save_new_label(@new_code, @bags_collected)

		put workers_courier_tasks_pickup_from_customer_step2_path(id: @order.id)

		expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step3_path(id: @order.id)
	end

	scenario 'worker did not print labels first and is kicked back with errors' do
		@order.save_new_label(@new_code, @bags_collected)

		put workers_courier_tasks_pickup_from_customer_step2_path(id: @order.id)

		expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step2_path(id: @order.id)
		expect(flash[:error]).to eq 'You must print labels first to continue'
	end
	
end
