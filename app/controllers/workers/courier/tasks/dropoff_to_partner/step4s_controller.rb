# frozen_string_literal: true

class Workers::Courier::Tasks::DropoffToPartner::Step4sController < ApplicationController
  before_action :authenticate_worker!
  before_action :get_partner_locations_for_select, only: %i[show]
  before_action :validate_form!, only: %i[update]

  include Workers::Courier::Tasks::Dropoffable

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find(params[:id])
    # @current_bags = @order.bag_codes.split(', ')
  end

  def update
    @order = Order.find(params[:id])
    @order.update_attribute(:partner_location_id, params[:partner_location])

    @order.mark_received_by_partner
    
    redirect_to workers_dashboards_waiting_orders_path, flash: {
      notice: 'Dropped off successfully!'
    }
  end

  private
  def validate_form!
    unless params[:id].present? && params[:partner_location].present?
      redirect_to workers_courier_tasks_dropoff_to_partner_step4_path(id: params[:id]), flash: {
        notice: 'You must select a valid partner to continue'
      }
    end
  end
end
