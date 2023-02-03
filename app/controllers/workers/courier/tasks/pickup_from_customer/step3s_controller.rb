# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromCustomer::Step3sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

	layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    
		if @order.valid_code?(params[:bags_code])
			@order.mark_collected_customer_bags

			redirect_to workers_courier_tasks_pickup_from_customer_step4_path(id: @order.id)
		else
			redirect_to workers_courier_tasks_pickup_from_customer_step3_path(id: params[:id]), flash: {
        notice: 'Invalid code.'
			}
		end
  end

  private

  def validate_form!
		unless params[:id].present? && 
			params[:bags_code].present?
      redirect_to workers_courier_tasks_pickup_from_customer_step3_path(id: params[:id]), flash: {
        notice: 'You need to fill out all fields to continue.'
      }
    end
  end
end
