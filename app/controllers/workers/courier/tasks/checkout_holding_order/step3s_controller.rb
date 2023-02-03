# frozen_string_literal: true

class Workers::Courier::Tasks::CheckoutHoldingOrder::Step3sController < ApplicationController
  include Workers::Courier::Tasks::ExistingScannable
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/courier/scan_existing_bags_layout'

  def show
    @order = Order.find_by(reference_code: params[:id])
  end

  def update
    @order = Order.find_by(reference_code: params[:id])

    @scanned_code = get_scanned_code(params)

    if codes_match?(@scanned_code, @order.bags_code)
      @order.mark_picked_up_by_customer

      redirect_to workers_dashboards_holding_orders_path, flash: {
        notice: 'Manual Checkout Completed.'
      }
    else
      redirect_to workers_courier_tasks_checkout_holding_order_step3_path(id: @order.reference_code), flash: {
        notice: 'You must scan all codes listed.'
      }
    end
  end

  private
  def validate_form!
    unless params[:id].present? && (params[:bags_code].present? || params[:manually_entered_code].present?)
      redirect_to workers_courier_tasks_checkout_holding_order_step3_path(id: params[:id]), flash: {
        notice: 'You must scan all codes listed.'
      }
    end
  end

end
