class Executives::Dashboards::Washers::ActivationsController < ApplicationController
  before_action :authenticate_executive!
  before_action :validate_params, only: %i[update]

  # executives_dashboards_washers_activations_path(id) PUT
  def update
    if @washer.not_initially_activated?
      @washer.initial_activate!
      @washer.send_initial_activation_email!

      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Washer Activated & Initial Activation Email Sent.'
      }
    else
      @washer.reactivate!
      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Washer Reactivated, and access to account has been restored.'
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