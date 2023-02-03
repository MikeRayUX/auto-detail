# frozen_string_literal: true

class Workers::Courier::Tasks::DeliverToCustomer::Step3sController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update]

  before_action :authenticate_worker!
	before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  # workers_courier_tasks_deliver_to_customer_step3_path GET
  def show
    @order = Order.find(params[:id])
		@user = @order.user
    @address = @user.address
  end

  # workers_courier_tasks_deliver_to_customer_step3s_path PUT
  def update
    @order = Order.find(params[:id])
    @user = @order.user

    @order.update_attributes(
      courier_stated_delivered_location: params[:delivery_location],
      global_status: 'delivered',
      deliver_to_customer_status: 'delivered_to_customer',
      delivered_to_customer_at: DateTime.current
    )
    
    @order.send_delivered_email!
    
    if @order.notifications.delivered.none?
      @user.send_sms_notification!(
        event = 'order_delivered',
        order = @order,
        message_body = 'Your Fresh And Tumble Laundry has been delivered! - So Fresh And Clean!' 
      )
    end

    redirect_to workers_dashboards_ready_for_deliveries_path, flash: {
      notice: 'Delivery Completed.'
    }
  end

	private
	
  def validate_form!
    unless params[:delivery_location].present? && params[:id].present?
      redirect_to workers_courier_tasks_deliver_to_customer_step3_path(id: params[:id]), flash: {
        notice: 'You must provide a valid delivery location.'
      }
    end
  end
end
