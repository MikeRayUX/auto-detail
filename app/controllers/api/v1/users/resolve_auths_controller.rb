# frozen_string_literal: true

class Api::V1::Users::ResolveAuthsController < ApiController
  # api_v1_users_resolve_auths_path
  # /api/v1/users/resolve_auths
  include Formattable
  def show
    # sleep 1.seconds
    if @current_user
      @address = @current_user.address
      render json: 
        {
          code: 200,
          status: 'ok',
          message: 'success',
          current_user: {
            full_name: @current_user.full_name.titleize,
            first_name: @current_user.first_name,
            email: @current_user.email.downcase
          },
          current_address: @address ? 
          {
            full_address: @address.full_address.upcase,
            pick_up_directions: @address.pick_up_directions,
            truncated_address: truncate_attribute(@address.street_address, 35).upcase,
            lat: @address.latitude,
            lng: @address.longitude 
          } : nil
        }
    else
      render json: 
        {
          code: 3000,
          status: :unauthorized,
          message: 'failure'
        }
    end
  end
end
