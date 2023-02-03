# frozen_string_literal: true

class Workers::Courier::Tasks::DropoffToPartner::Step3sController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])

    @order.mark_recorded_partner_weight(params[:weight])
    redirect_to workers_courier_tasks_dropoff_to_partner_step4_path(id: @order.id)
  end

  private
  def validate_form!
    unless params[:id].present? && params[:weight].present? && params[:weight].to_f > 0
      redirect_to workers_courier_tasks_dropoff_to_partner_step3_path(id: params[:id]), flash: {
        notice: 'You must enter a valid weight to continue.'
      }
    end
  end
end
