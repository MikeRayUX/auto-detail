# frozen_string_literal: true

class Workers::Courier::Tasks::DeliverToCustomer::Step2sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]
  include Workers::Courier::Tasks::ExistingScannable

  layout 'workers/no_nav_layout'

  def show
		@order = Order.find(params[:id])
		@address = @order.user.address
  end

  def update
    @order = Order.find(params[:id])
    @scanned_code = get_scanned_code(params)
    
    if codes_match?(@scanned_code, @order.bags_code)
      @order.mark_scanned_existing_bags_for_delivery

      redirect_to workers_courier_tasks_deliver_to_customer_step3_path(id: @order.id)
    else
      redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: @order.id), flash: {
        notice: 'You must scan the correct code.'
      }
    end
  end

  private
  def validate_form!
    unless params[:id].present? && (params[:bags_code].present? || params[:manually_entered_code].present?)
      redirect_to workers_courier_tasks_deliver_to_customer_step2_path(id: params[:id]), flash: {
        notice: 'You must scan the correct code.'
      }
    end
  end
end
