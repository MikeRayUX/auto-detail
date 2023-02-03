# frozen_string_literal: true

class Api::V1::Users::Dashboards::AccountSettings::UpdateAddressesController < ApiController
  include Formattable

  # api_v1_users_dashboards_account_settings_update_addresses_path
  # a
  def update
    # sleep 1.seconds
    @address = @current_user.build_address(address_params)
    if @address.save
      @address.attempt_region_attach
      render(json: {
               code: 200,
               status: 'ok',
               message: 'address_saved',
               feedback: 'Address updated successfully!',
               current_address: {
                full_address: @address.full_address.upcase,
                pick_up_directions: @address.pick_up_directions,
                truncated_address: truncate_attribute(@address.street_address, 35).upcase,
                lat: @address.latitude,
                lng: @address.longitude 
              }
             })
    else
      render(json: {
               code: 3000,
               status: 'ok',
               message: 'address_invalid',
               errors: @address.errors.full_messages[0]
             })
    end
  end

  def address_params
    params.require(:address).permit(%i[street_address unit_number city state zipcode pick_up_directions])
  end
end
