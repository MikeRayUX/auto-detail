class Workers::Courier::Tasks::Commercial::PickupFromPartnersController < ApplicationController
  layout 'workers/no_nav_layout'
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  # workers_courier_tasks_commercial_pickup_from_partners_path GET
  def show
    @pickup = CommercialPickup.find(params[:id])
    @partner = @pickup.partner_location
  end

  # workers_courier_tasks_commercial_pickup_from_partners_path PUT
  def update
    @pickup = CommercialPickup.find(params[:id])
    @client = @pickup.client

    @pickup.update_attribute(:bags_collected, params[:bags_collected])
    @pickup.record_partner_weight(params[:weight])

    @pickup.mark_picked_up_from_partner

    redirect_to workers_dashboards_processing_orders_path, flash: {
      notice: 'Pickup from partner completed.'
    }
  end

  private

  def validate_form!
    unless params[:weight].present? && (params[:weight].to_i > 0) && params[:id].present? && params[:bags_collected].present?
      redirect_to workers_courier_tasks_commercial_pickup_from_partners_path(id: params[:id]), flash: {
        notice: 'You must enter a valid weight to continue.'
      }
    end
  end
end
