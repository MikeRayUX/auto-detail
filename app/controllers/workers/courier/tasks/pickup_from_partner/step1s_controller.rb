# frozen_string_literal: true

class Workers::Courier::Tasks::PickupFromPartner::Step1sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
    @partner = @order.partner_location
  end

  # workers_courier_tasks_pickup_from_partner_step1_path
  def update
    @order = Order.find(params[:id])

    @order.mark_arrived_at_partner_for_pickup

    if params[:unwashable_items] == "true"
      @order.update_attribute(:unwashable_items, true)
    else
      @order.update_attribute(:unwashable_items, false)
    end

    redirect_to workers_courier_tasks_pickup_from_partner_step2_path(id: @order.id)
  end

  private
  
  def validate_form!
    unless params[:id].present?
      redirect_to workers_courier_tasks_pickup_from_partner_step1_path(id: params[:id]), flash: {
        notice: 'Something went wrong.'
      }
    end
  end
end
