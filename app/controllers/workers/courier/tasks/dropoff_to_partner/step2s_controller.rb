# frozen_string_literal: true

class Workers::Courier::Tasks::DropoffToPartner::Step2sController < ApplicationController
  include Workers::Courier::Tasks::ExistingScannable
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])

    @scanned_code = get_scanned_code(params)

    if codes_match?(@scanned_code, @order.bags_code)
      @order.mark_scanned_for_partner_dropoff
      
      redirect_to workers_courier_tasks_dropoff_to_partner_step3_path(id: @order.id)
    else
      redirect_to workers_courier_tasks_dropoff_to_partner_step2_path(id: @order.id), flash: {
        notice: 'You must scan or enter bags code before continuing.'
      }
    end
  end

  private

  def validate_form!
    unless params[:bags_code].present? || params[:manually_entered_code].present?
      redirect_to workers_courier_tasks_dropoff_to_partner_step2_path(id: params[:id]), flash: {
        notice: 'You must scan or enter bags code before continuing.'
      }
    end
  end

end
