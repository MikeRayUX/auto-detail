# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromPartner::Step3sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]
  include Workers::Courier::Tasks::ExistingScannable

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    @scanned_code = get_scanned_code(params)

    if @order.valid_code?(params[:bags_code])
      @order.mark_picked_up_from_partner

      redirect_to workers_dashboards_processing_orders_path, flash: {
				notice: 'Pickup from partner completed.'
			}
    else
      redirect_to workers_courier_tasks_pickup_from_partner_step3_path(id: @order.id), flash: {
        notice: 'You must scan all codes listed.'
      }
    end
  end

  private
  def validate_form!
		unless params[:id].present? && params[:bags_code].present?
      redirect_to workers_courier_tasks_pickup_from_partner_step3_path(id: params[:id]), flash: {
        notice: 'You must scan all codes listed.'
      }
    end
  end
end
