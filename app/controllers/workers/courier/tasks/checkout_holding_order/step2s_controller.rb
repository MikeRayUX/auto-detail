# frozen_string_literal: true

class Workers::Courier::Tasks::CheckoutHoldingOrder::Step2sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find_by(reference_code: params[:id])
  end

  def update
    @order = Order.find_by(reference_code: params[:id])

    @order.mark_acknowledged_directions_for_manual_checkout

    redirect_to workers_courier_tasks_checkout_holding_order_step3_path(id: @order.reference_code)
  end

  private
  def validate_form!
    unless params[:id].present?
      redirect_to workers_courier_tasks_checkout_holding_order_step2_path(id: params[:id]), flash: {
        notice: 'Something went wrong.'
      }
    end
  end
end
