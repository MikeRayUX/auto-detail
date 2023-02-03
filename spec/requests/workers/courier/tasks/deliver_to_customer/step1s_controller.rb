# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'deliver to customer controller step1s', type: :request do
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

    sign_in @worker
  end

  after do
    sign_out @worker
  end

  scenario 'worker views the customers order information and address for traveling to customer to pickup order' do
    get workers_courier_tasks_deliver_to_customer_step1_path(id: @order.id)

		@page = response.body

		expect(@page).to include(Address.first.readable_pickup_directions)
		expect(@page).to include(@order.google_nav_link)
  end

  scenario 'worker marks that they have arrived and moves on to step2' do
    put workers_courier_tasks_deliver_to_customer_step1_path(id: @order.id)
    
    expect(Order.first.deliver_to_customer_status).to eq('arrived_at_customer_for_delivery')
    expect(response).to redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
  end
end
