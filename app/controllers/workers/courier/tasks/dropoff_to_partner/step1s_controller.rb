# frozen_string_literal: true

class Workers::Courier::Tasks::DropoffToPartner::Step1sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    
    @order.mark_arrived_at_partner_for_dropoff
    redirect_to workers_courier_tasks_dropoff_to_partner_step2_path(id: @order.id)
  end

  private
  def validate_form!
    unless params[:id].present?
      redirect_to workers_courier_tasks_dropoff_to_partner_step1_path(id: params[:id]), flash: {
        notice: 'Something went wrong.'
      }
    end
  end
end
