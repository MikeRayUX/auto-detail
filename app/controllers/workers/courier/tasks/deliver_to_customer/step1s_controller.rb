# frozen_string_literal: true

class Workers::Courier::Tasks::DeliverToCustomer::Step1sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'
  
  def show
    @order = Order.find(params[:id])
    @address = @order.user.address
  end

  def update
    @order = Order.find(params[:id])

    @order.mark_arrived_at_customer_for_delivery

    redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id)
  end

  private
  def validate_form!
    unless params[:id].present?
      redirect_to workers_courier_tasks_deliver_to_customer_step1_path(id: params[:id]), flash: {
        notice: 'Something went wrong'
      }
    end
  end
end
