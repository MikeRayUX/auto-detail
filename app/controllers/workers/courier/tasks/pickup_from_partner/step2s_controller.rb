# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromPartner::Step2sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])

    @order.mark_acknowledged_partner_pickup_directions

    redirect_to workers_courier_tasks_pickup_from_partner_step3_path(id: @order.id)
  end

  private

  def validate_form!
    unless params[:id].present?
      redirect_to workers_courier_tasks_pickup_from_partner_step2_path(id: params[:id]), flash: {
        notice: 'Something went wrong.'
      }
    end
  end
end
