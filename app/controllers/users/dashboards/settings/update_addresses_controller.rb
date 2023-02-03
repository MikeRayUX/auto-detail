# frozen_string_literal: true

class Users::Dashboards::Settings::UpdateAddressesController < ApplicationController
	before_action :authenticate_user!
	before_action :ensure_address_exists

  layout 'users/dashboards/user_dashboard_layout'

  def show; end

	def update
		@user = current_user
		@address = current_user.address

		if @address.update_attributes(address_params)
			@address.attempt_region_attach

			if @user.waiting_for_delivery_reattempts?
				@user.update_reattempts_with_new_address
			end

      redirect_to users_dashboards_settings_info_summaries_path, flash: {
        success: 'Address Updated!'
      }
    else
      redirect_to users_dashboards_settings_update_addresses_path, flash: {
        error: 'Invalid address.'
      }
    end
  end

	private
	
	def ensure_address_exists
		unless current_user.address.present?
			redirect_to users_dashboards_settings_info_summaries_path, flash: {
				error: "You don't have an address to update."
			}
		end	
	end

  def address_params
    params.require(:address).permit(:street_address, :unit_number, :city, :state, :zipcode, :pick_up_directions)
  end
end
