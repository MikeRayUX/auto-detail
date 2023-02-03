class Executives::Dashboards::Washers::InvitationsController < ApplicationController
  before_action :authenticate_executive!

  # executives_dashboards_washers_invitations_path
  def update
    @washer = Washer.find(params[:id])
    @washer.skip_finalized_washer_attributes = true

    @temp_password = Devise.friendly_token.first(6)

    if @washer.assign_password(@temp_password)
      @washer.invite_for_onboard!(@temp_password)
      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: 'Invitation Sent Successfully'
      }
    else
      redirect_to executives_dashboards_washers_washer_path(@washer.id), flash: {
        notice: @washer.errors.full_message.first
      }
    end
  end
end