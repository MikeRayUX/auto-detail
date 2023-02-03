# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromCustomer::Step2sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
		@order = Order.find(params[:id])
		@user = @order.user
    @address = @order.user.address
  end

  def update
    @order = Order.find(params[:id])
		if @order.pickup_labels_printed?
			@order.mark_acknowledged_pickup_directions
			redirect_to workers_courier_tasks_pickup_from_customer_step3_path(id: @order.id)
		else
			redirect_to workers_courier_tasks_pickup_from_customer_step2_path(id: @order.id), flash: {
				error: "You must print labels first to continue"
			}
		end
  end

  private

  def validate_form!
    unless params[:id].present?
      redirect_to workers_courier_tasks_pickup_from_customer_step2_path(id: params[:id]), flash: {
        notice: 'You must acknowledge directions to continue.'
      }
    end
  end
end
