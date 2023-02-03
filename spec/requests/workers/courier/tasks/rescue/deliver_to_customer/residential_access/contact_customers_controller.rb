# frozen_string_literal: true

require 'rails_helper'
require 'order_helper'
RSpec.describe 'rescue deliver to customer residential access contact customers controller', type: :request do
  before do
    DatabaseCleaner.clean_with(:truncation)
		ActionMailer::Base.deliveries.clear
		@region = create(:region)
    @pricing = create(:region_pricing)
    @user = create(:user, :with_payment_method)
    @address = @user.create_address!(attributes_for(:address))

    @worker = create(:worker, :with_region)
    @new_bags_code = get_new_bags_code
    @bags_collected = rand(1..5)
    @courier_weight = get_random_weight
    @order = @user.orders.create!(
      attributes_for(:order).merge(
        region_pricing_id: @pricing.id,
        full_address: @address.full_address,
        routable_address: @address.address,
        bags_code: @new_bags_code,
        bags_collected: @bags_collected,
        courier_weight: @courier_weight
    ))

    @partner_location = @order.create_partner_location(attributes_for(:partner_location))

		@partner_reported_weight = get_random_weight
 
    @order.mark_recorded_partner_weight(@partner_reported_weight)

    @order.mark_scanned_existing_bags_for_delivery

    sign_in @worker
  end

  after do
    DatabaseCleaner.clean_with(:truncation)
    ActionMailer::Base.deliveries.clear
    sign_out @worker
  end

  scenario 'worker views the questionaire' do
    get new_workers_courier_tasks_rescue_deliver_to_customer_residential_access_contact_customers_path(id: @order.id)

    expect(response.body).to include('What is the problem?')
  end

  scenario 'worker made a selection on the questionaire and the order is marked as attempted delivery, a delivery attempt email is sent and the order is charged' do
    @problem_encountered = get_random_delivery_problem
    post workers_courier_tasks_rescue_deliver_to_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: @problem_encountered
    }
    
    @order.reload
    @courier_problem = @order.courier_problems.last

    # order
    expect(@order.delivery_attempts).to eq(1)
    expect(@order.courier_problems.count).to eq(1)
    expect(@order.transactions.count).to eq 0
    # problem
    expect(@courier_problem.order_id).to eq(@order.id)
    expect(@courier_problem.occured_during_task).to eq('deliver_to_customer')
    expect(@courier_problem.occured_during_step).to eq('step3')
    expect(@courier_problem.problem_encountered).to eq(@problem_encountered)
    expect(@courier_problem.address).to eq(@order.full_address)

    expect(response).to redirect_to workers_dashboards_ready_for_deliveries_path
  end

  scenario 'the attemp count has been exceeded and the order is marked as undeliverable' do
    create_stripe_customer!

    @order.update_attribute(:delivery_attempts, Order::DELIVERY_ATTEMPT_LIMIT)

    @problem_encountered = get_random_delivery_problem
    post workers_courier_tasks_rescue_deliver_to_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: @problem_encountered
    }
    
    @order.reload
    @courier_problem = @order.courier_problems.last

    # order
    expect(@order.delivery_attempts).to eq(4)
    expect(@order.courier_problems.count).to eq(1)
    expect(@order.global_status).to eq 'in_holding_unable_to_deliver'
    # problem
    expect(@courier_problem.order_id).to eq(@order.id)
    expect(@courier_problem.occured_during_task).to eq('deliver_to_customer')
    expect(@courier_problem.occured_during_step).to eq('step3')
    expect(@courier_problem.problem_encountered).to eq(@problem_encountered)
    expect(@courier_problem.address).to eq(@order.full_address)

    expect(response).to redirect_to workers_dashboards_ready_for_deliveries_path
  end

  scenario 'worker does not make a valid selection on the questionaire and is kicked back' do
    post workers_courier_tasks_rescue_deliver_to_customer_residential_access_contact_customers_path, params: {
      id: @order.id,
      problem_encountered: ''
    }

    expect(flash[:error]).to eq('You must enter a selection')
    expect(response).to redirect_to workers_courier_tasks_rescue_deliver_to_customer_residential_access_contact_customers_path(id: @order.id)

    expect(@order.delivery_attempts).to eq(0)
    expect(@order.courier_problems.count).to eq(0)
    expect(CourierProblem.count).to eq(0)
  end
end
