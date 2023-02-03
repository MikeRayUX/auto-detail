# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'pickup from customer step3s controller spec', type: :request do
  before do
		DatabaseCleaner.clean_with(:truncation)
		@region = create(:region)

    @user = create(:user)
    @address = @user.create_address!(attributes_for(:address))
    @worker = create(:worker, :with_region)
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        full_address: @address.full_address,
				routable_address: @address.address,
				bags_code: get_new_bags_code,
				bags_collected: rand(1..5)
    ))

    @order.mark_acknowledged_pickup_directions

    sign_in @worker
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    sign_out @worker
  end

  scenario 'worker views scan directions and order details' do
    get workers_courier_tasks_pickup_from_customer_step3_path, params: {
      id: @order.id
    }

    page = response.body

    expect(page).to include('Pickup Step 3. Scan New Label')
    expect(page).to include('Scan the correct code below')
    expect(page).to include("Bags: #{@order.bags_collected}")
    expect(page).to include("<span class='requiredCode text-3xl' marked-as-scanned='false'>#{@order.bags_code}</span>")
  end

  scenario 'worker used the label tool, generated codes and labels and enters the valid code' do
    put workers_courier_tasks_pickup_from_customer_step3_path, params: {
      id: @order.id,
      bags_code: @order.bags_code
    }

    expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step4_path(id: @order.id)
  end

  scenario 'worker does not include a bags code with the form and is kicked back to the form' do
    put workers_courier_tasks_pickup_from_customer_step3_path, params: {
      id: @order.id,
      bags_code: ''
    }

    expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step3_path(id: @order.id)
    expect(flash[:notice]).to eq('You need to fill out all fields to continue.')
  end

  scenario 'worker does not enter the correct code and is kicked back' do
    put workers_courier_tasks_pickup_from_customer_step3_path, params: {
      id: @order.id,
      bags_code: 'koasudhf'
    }

    expect(response).to redirect_to workers_courier_tasks_pickup_from_customer_step3_path(id: @order.id)

    expect(flash[:notice]).to eq('Invalid code.')
  end
end
