# frozen_string_literal: true

class Api::V1::Users::Dashboards::AccountSettings::UpdatePickupDirectionsController < ApiController

  # PATCH
  # api_v1_users_dashboards_account_settings_update_pickup_directions_path
  # /api/v1/users/dashboards/account_settings/update_pickup_directions
  def update
    # sleep 1.seconds
    @address = @current_user.address
    if @address.update_attribute(:pick_up_directions, pick_up_directions_params[:pick_up_directions])
      render(json: {
               code: 200,
               message: 'directions_updated'
             })
    else
      render(json: {
               code: 3000,
               message: 'invalid_directions',
               data: {
                 errors: @address.errors.full_messages[0]
               }
             })
    end
 end

  def pick_up_directions_params
    params.require(:pick_up_directions).permit(:pick_up_directions)
  end
end
