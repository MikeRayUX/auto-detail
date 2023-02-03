# frozen_string_literal: true

class Workers::Courier::Tasks::Rescue::PickupFromCustomer::ResidentialAccess::ContactCustomersController < ApplicationController

  layout 'workers/no_nav_layout'

  before_action :authenticate_worker!

  # new_workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path GET
  def new
    @order = Order.find(params[:id])
    @address = @order.user.address
  end

  # workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path GET
  def show 
    @order = Order.find(params[:id])
    @customer = @order.user
    @address = @customer.address
    @problem_encountered = params[:problem_encountered]

    if customer_cancelled?
      # skip call customer step
      @customer = @order.user
      @problem = current_worker.courier_problems.new(
        order_id: @order.id,
        occured_during_task: 'pickup_from_customer',
        occured_during_step: 'step2',
        problem_encountered: params[:problem_encountered],
        address: @order.full_address
      )

      if @problem.save
        @order.mark_unable_to_pick_up!
        @problem.send_unable_to_pickup_email!
        redirect_to workers_dashboards_open_appointments_path, flash: {
          notice: 'Your response has been recorded.'
        }
      else
        redirect_to new_workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path(id: @order.id), flash: {
          notice: 'Something went wrong.'
        }
      end
    end
  end

  # workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path POST
  def create
    @order = Order.find(params[:id])
    @customer = @order.user

    @problem = current_worker.courier_problems.new(
      order_id: @order.id,
      occured_during_task: 'pickup_from_customer',
      occured_during_step: 'step2',
      problem_encountered: params[:problem_encountered],
      address: @order.full_address
    )

    if @problem.save
      @order.mark_unable_to_pick_up!
      @problem.send_unable_to_pickup_email!
      redirect_to workers_dashboards_open_appointments_path, flash: {
        notice: 'Your response has been recorded.'
      }
    else
      redirect_to new_workers_courier_tasks_rescue_pickup_from_customer_residential_access_contact_customers_path(id: @order.id), flash: {
        notice: 'Something went wrong.'
      }
    end
  end

  private
    def customer_cancelled?
      @problem_encountered == 'customer_cancelled'
    end
end
