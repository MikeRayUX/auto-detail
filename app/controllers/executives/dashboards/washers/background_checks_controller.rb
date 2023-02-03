class Executives::Dashboards::Washers::BackgroundChecksController < ApplicationController
  before_action :authenticate_executive!

  # executives_dashboards_washers_background_checks_path
  def update
    @washer = Washer.find_by(email: params[:email])

    if params[:approve] == "true"
      @washer.approve_background_check!

      redirect_to executives_dashboards_washers_washer_path(id: @washer.id), flash: {
        notice: 'Background check approved'
      }
    else
      @washer.undo_background_check_approval!

      redirect_to executives_dashboards_washers_washer_path(id: @washer.id), flash: {
        notice: 'Background check revoked'
      }
    end
  end

end