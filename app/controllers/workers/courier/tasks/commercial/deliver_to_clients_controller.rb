class Workers::Courier::Tasks::Commercial::DeliverToClientsController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  # workers_courier_tasks_commercial_deliver_to_clients_path GET
  def show
    @pickup = CommercialPickup.find(params[:id])
    @client = @pickup.client
  end

  # workers_courier_tasks_commercial_deliver_to_clients_path PUT
  def update
    @pickup = CommercialPickup.find(params[:id])
    @pickup.mark_delivered_to_client(params[:delivery_location])
    @pickup.save_charge

    redirect_to workers_dashboards_ready_for_deliveries_path, flash: {
      notice: 'Delivery Completed.'
    }
  end

  private
  def validate_form!
    unless params[:delivery_location].present?
      redirect_to workers_courier_tasks_commercial_deliver_to_clients_path(id: params[:id]), flash: {
        notice: 'You must make a selection to continue.'
      }
    end
  end
end
