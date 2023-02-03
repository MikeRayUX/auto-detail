# frozen_string_literal: true

class Users::ResolveSetupsController < ApplicationController
  before_action :authenticate_user!
  
  layout 'users/dashboards/user_dashboard_layout'

  # GET users_resolve_setups_path 
  def index
    if current_user.completed_setup?
      redirect_to new_users_dashboards_new_order_flow_pickups_path
    else
      redirect_to new_users_resolve_setup_path
    end
  end

  # GET new_users_resolve_setup_path
  def new; end

  # POST users_resolve_setups_path
  def create
    @address = current_user.build_address(address_params)
    if @address.valid?
			@address.save!
			@address.attempt_region_attach
      redirect_to users_resolve_setups_path
    else
      redirect_to users_resolve_setups_path, flash: {
        error: 'Invalid address.'
      }
    end
  end

  def address_params
    params.require(:address).permit(:street_address, :city, :state, :zipcode, :unit_number, :pick_up_directions)
  end
end
