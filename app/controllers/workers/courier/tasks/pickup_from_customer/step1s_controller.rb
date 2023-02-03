# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromCustomer::Step1sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
		@user = @order.user
    @address = @user.address

    if @order.startable? 
      @order.mark_pick_up_started
      if @order.notifications.enroute_for_pickup.none?
        @user.send_sms_notification!(
          event = 'enroute_to_customer_for_pickup',
          order = @order,
          message_body = 'Your Fresh And Tumble Courier is on their way for pickup!'
        )
      end
    else
      redirect_to workers_dashboards_open_appointments_path, flash: {
        error: "Cannot start pickup. Either too early or order has been cancelled."
      }
    end
  end

  def update
    @order = Order.find(params[:id])
    @user = @order.user
    
    if @order.notifications.arrived.none?
      @user.send_sms_notification!(
        event = 'arrival_for_pickup',
        order = @order,
        message_body = 'Your Fresh And Tumble Courier has just arrived for pickup!'
      )
    end
		
		@order.mark_arrived_for_pickup

    redirect_to workers_courier_tasks_pickup_from_customer_step2_path(id: @order.id)
  end

  private
    def validate_form!
      unless params[:id].present?
        redirect_to workers_courier_tasks_pickup_from_customer_step1_path(id: params[:id]), flash: {
          notice: 'You must be at the address in order to continue'
        }
      end
    end
end
