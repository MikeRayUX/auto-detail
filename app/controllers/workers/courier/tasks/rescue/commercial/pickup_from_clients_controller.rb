class Workers::Courier::Tasks::Rescue::Commercial::PickupFromClientsController < ApplicationController
  before_action :authenticate_worker!
  before_action :validate_form!, only: %i[update]

  layout 'workers/no_nav_layout'

  # workers_courier_tasks_rescue_commercial_pickup_from_clients_path GET
  def show
    @pickup = CommercialPickup.find(params[:id])
  end

  # workers_courier_tasks_rescue_commercial_pickup_from_clients_path PUT
  def update
    @pickup = CommercialPickup.find(params[:id])

    @pickup.problem_cancel!(params[:problem_encountered])

    redirect_to workers_dashboards_open_appointments_path, flash: {
      notice: 'Your response has been recorded.'
    }
  end

  private
  def validate_form!
    unless params[:problem_encountered].present?
      redirect_to workers_courier_tasks_rescue_commercial_pickup_from_clients_path(id: params[:id]), flash: {
        notice: 'You must make a selection to continue.'
      }
    end

  end
end
