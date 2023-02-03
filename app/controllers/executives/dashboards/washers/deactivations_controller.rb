class Executives::Dashboards::Washers::DeactivationsController < ApplicationController
  before_action :authenticate_executive!
  before_action :validate_params, only: %i[update]

  # executives_dashboards_washers_deactivations_path(id) PUT
  def update
    if @washer.deactivatable?
      @washer.deactivate!
      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Washer deactivated. They can no longer sign in to the washer app.'
      }
    else
      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Washer cannot be deactivated. Waher is not deactivatable.'
      }
    end
  end

  private
  def validate_params
    unless params[:id].present? && Washer.find(params[:id])
      redirect_to executives_dashboards_washers_washers_path, flash: {
        notice: 'Invalid washer please try again'
      } 
    else
      @washer = Washer.find(params[:id])
    end
  end
end