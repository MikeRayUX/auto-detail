# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'drop off to customer step1s controller', type: :request do
  before do
		DatabaseCleaner.clean_with(:truncation)
    @region = create(:region)
    @pricing = create(:region_pricing)

    @user = create(:user, :with_payment_method)
    @address = @user.create_address!(attributes_for(:address).merge(region_id: @region.id))
    @worker = create(:worker, :with_region)
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
        routable_address: @address.address
    ))

    @courier_weight = get_random_weight

    @order.update_attributes(
      global_status: 'picked_up',
      pick_up_from_customer_status: 'picked_up_from_customer',
      courier_weight: @courier_weight,
      picked_up_from_customer_at: DateTime.current
    )

    mock_charged_order!

    sign_in @worker
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    sign_out @worker
  end

  scenario 'worker views the first step in dropoff to partner' do
    get workers_courier_tasks_dropoff_to_partner_step1_path(id: @order.id)

    page = response.body

    expect(page).to include('Step 1. Dropoff To Washer')
    expect(page).to include(@order.readable_detergent)
    expect(page).to include(@order.readable_softener)
  end

  scenario 'worker marks that theyve arrived and moves on to step2' do
    put workers_courier_tasks_dropoff_to_partner_step1_path(id: @order.id)

    expect(Order.first.drop_off_to_partner_status).to eq('arrived_at_partner_for_dropoff')

    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step2_path(id: @order.id)
  end

  scenario 'worker doesnt provide order reference code in the url and is kicked back' do
    put workers_courier_tasks_dropoff_to_partner_step1_path

    expect(response).to redirect_to workers_courier_tasks_dropoff_to_partner_step1_path
    expect(flash[:notice]).to eq('Something went wrong.')
  end
end
