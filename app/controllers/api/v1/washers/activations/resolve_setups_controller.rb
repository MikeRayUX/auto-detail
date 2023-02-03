# frozen_string_literal: true

class Api::V1::Washers::Activations::ResolveSetupsController < Api::V1::Washers::AuthsController
  # /api/v1/washers/activations/resolve_setups/ GET
  def index
    if @current_washer.completed_activation_steps? && @current_washer.activated?

      @address = @current_washer.address
      render json: {
        status: :ok,
        code: 200,
        message: 'setup_resolved',
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
        message: 'setup_not_resolved'
      }
    end
  end
  
end
