class Api::V1::Washers::LocationsController < Api::V1::Washers::AuthsController

  # PUT
  # /api/v1/washers/locations/1
  # api_v1_washers_location_path
  def update
    if washer_params[:current_lat].present? && 
      washer_params[:current_lng].present?
      @current_washer.update_location(
        washer_params[:current_lat],
        washer_params[:current_lng]
      )
      render json: {
        code: 204,
        message: 'location_updated',
        current_location: {
          lat: @current_washer.current_lat,
          lng: @current_washer.current_lng
        }
      }
    else
      render json: {
        code: 3000,
        message: 'missing_location'
      }
    end
  end

  private
  def washer_params
    params.require(:washer).permit(%i[current_lat current_lng])
  end

  def check_activation_status
    unless @current_washer.activated?
      @current_washer.go_offline
      render json: {
        code: 3000,
        message: 'not_activated',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
      }
    end
  end
end