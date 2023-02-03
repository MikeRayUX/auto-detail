class Api::V1::Washers::ResolveAuthsController < Api::V1::Washers::AuthsController
  # api_v1_washers_resolve_auths_path
  # /api/v1/washers/resolve_auths
  def index
    if @current_washer.completed_activation_steps? && @current_washer.activated?

      @address = @current_washer.address
      render json: {
        status: :ok,
        code: 200,
        message: 'authenticated_and_setup_resolved',
        washer: {
          full_name: @current_washer.full_name.upcase,
          email: @current_washer.email
        },
        home_address: {
          full_address: @address.full_address,
          lat: @address.latitude,
          lng: @address.longitude
        }
      }
    else 
      render json: {
        status: :ok,
        code: 200,
        message: 'authenticated_but_setup_not_resolved'
      }
    end
  end
end