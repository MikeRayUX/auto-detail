# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'pickup from partner controller spec step2s', type: :request do
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

  scenario 'views pickup from partner step 2 directions' do
    get workers_courier_tasks_pickup_from_partner_step2_path(id: @order.id)

    page = response.body


    expect(page).to include("Step 2. Pickup From Washer")

    expect(page).to include("#{@order.bags_code} (about #{@order.bags_collected} bags)")
  end

  scenario 'worker acknowledges directions and moves forward and the order status is updated' do
    put workers_courier_tasks_pickup_from_partner_step2_path(id: @order.id)

    expect(Order.first.pick_up_from_partner_status).to eq('acknowledged_partner_pickup_directions')

    expect(response).to redirect_to workers_courier_tasks_pickup_from_partner_step3_path(id: @order.id)
  end
end
