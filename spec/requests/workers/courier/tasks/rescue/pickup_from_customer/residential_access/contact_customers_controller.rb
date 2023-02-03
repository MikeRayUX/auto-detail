# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'rescue pickup from customer residential access contact customers controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
		@region = create(:region)
    @user = create(:user)
    @pricing = create(:region_pricing)
    @address = @user.create_address!(attributes_for(:address).merge(
      pick_up_directions: 'back door'
    ))
    @worker = create(:worker, :with_region)
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        region_pricing_id: @pricing.id,
        full_address: @address.full_address,
        routable_address: @address.address
    ))
    sign_in @worker
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    sign_out @worker
  end

  scenario 'worker encounters an issue at the customer location and views the questionaire' do
    get new_workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path(id: @order.id)

    expect(response.body).to include('What is the problem?')
  end

  scenario 'worker makes a selection from the questionaire form' do
    @problem_selection = get_random_pickup_problem
    get workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: @problem_selection
    }

    @page = response.body

    expect(@page).to include('Contact The Customer:')
    expect(@page).to include(@user.formatted_phone)
    expect(@page).to include(@address.readable_pickup_directions)
  end

  scenario 'worker select customer cancelled and the order is cancelled and the worker is taken back to the open appointments page' do
    get workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: 'customer_cancelled'
    }

    expect(response).to redirect_to workers_dashboards_open_appointments_path
    expect(flash[:notice]).to eq 'Your response has been recorded.'

    @problem = @order.courier_problems.last

    expect(@problem.occured_during_task).to eq 'pickup_from_customer'
    expect(@problem.occured_during_step).to eq 'step2'
    expect(@problem.problem_encountered).to eq 'customer_cancelled'
  end

  scenario 'worker marks that they have contacted the customer and the order is cancelled and they receive an email' do
    @problem_selection = get_random_pickup_problem
    post workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: @problem_selection
    }
    
    expect(response).to redirect_to workers_dashboards_open_appointments_path

    expect(@order.courier_problems.count).to eq(1)
    expect(@worker.courier_problems.count).to eq(1)
    expect(Order.first.global_status).to eq('cancelled_unable_to_pickup')
    expect(flash[:notice]).to eq('Your response has been recorded.')
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end

  scenario 'worker does not provide a an answer to the questionaire and is kicked back' do
    post workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: ''
    }

    expect(response).to  redirect_to new_workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path(id: @order.id)
    expect(ActionMailer::Base.deliveries.count).to eq(0)
    expect(flash[:notice]).to eq('Something went wrong.')
  end
end
