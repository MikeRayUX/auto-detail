class Workers::Courier::Tasks::Commercial::DropoffToPartnersController < ApplicationController
  include Workers::Courier::Tasks::Dropoffable

  before_action :authenticate_worker!
  before_action :get_partner_locations_for_select, only: %i[show]
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'
  # workers_courier_tasks_commercial_dropoff_to_partners_path GET
  def show
    @pickup = CommercialPickup.find(params[:id])
  end

  # workers_courier_tasks_commercial_dropoff_to_partners_path PUT
  def update
    @pickup = CommercialPickup.find(params[:id])
    @pickup.update_attribute(:partner_location_id, params[:partner_location_id])

    @pickup.mark_received_by_partner
    
    redirect_to workers_dashboards_waiting_orders_path, flash: {
      notice: 'Dropped off successfully!'
    }
  end

  private
  def validate_form!
    unless params[:id].present? && params[:partner_location_id].present?
      redirect_to workers_courier_tasks_commercial_dropoff_to_partners_path(id: params[:id]), flash: {
        notice: 'You must select a valid partner to continue'
      }
    end
  end
end
