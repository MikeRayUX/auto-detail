# frozen_string_literal: true

class Workers::Courier::Tasks::Rescue::DeliverToCustomer::ResidentialAccess::ContactCustomersController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[create]

  layout 'workers/no_nav_layout'

  def new
    @order = Order.find(params[:id])
    @address = @order.user.address
  end

  def show
    @order = Order.find(params[:id])
    @customer = @order.user
    @address = @customer.address
    @problem_encountered = params[:problem_encountered]
  end

  def create
    @order = Order.find(params[:id])
    @customer = @order.user
    @order.increment!(:delivery_attempts)
    @courier_problem = current_worker.courier_problems.create!(
      order_id: @order.id,
      occured_during_task: 'deliver_to_customer',
      occured_during_step: 'step3',
      problem_encountered: params[:problem_encountered],
      address: @order.full_address
    )
    
    if @order.delivery_limit_reached?
      @order.mark_as_undeliverable
    else
      @order.mark_for_reattempt
    end

    Users::Orders::UnableToDeliverMailerWorker.perform_async(
      @order.id,
      @customer.id,
      @courier_problem.id
    )
    
    redirect_to workers_dashboards_ready_for_deliveries_path, flash: {
      notice: 'Your response has been recorded.'
    }
  end

  private

  def validate_form!
    unless params[:id].present? && params[:problem_encountered].present?
      redirect_to workers_courier_tasks_rescue_deliver_to_customer_residential_access_contact_customers_path(id: params[:id]), flash: {
        error: 'You must enter a selection'
      }
    end
  end
    
end
