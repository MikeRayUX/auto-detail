class Executives::Dashboards::Washers::ResendActivationEmailsController < ApplicationController
  before_action :authenticate_executive!
  before_action :validate_params, only: %i[update]

  # executives_dashboards_washers_resend_activation_emails_path(id) PUT
  def update
    if @washer.activated?
      
      @washer.send_initial_activation_email!

      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Washer Initial Activation Email Has Been Resent.'
      }
    else
      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Email not sent. Washer is not active. You must activate the washer first.'
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