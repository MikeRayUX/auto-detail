# frozen_string_literal: true

class Api::V1::Users::ResolveSetupsController < ApiController
  # after_action :debug_undo, only: %i[create]
  before_action :completed_setup?, only: %i[show]
  before_action :within_region?, only: %i[show]

  include Formattable
  # GET
  # api_v1_users_resolve_setups_path
  # /api/v1/users/resolve_setups
  def show
    # sleep 1.seconds
    detergents = [
      {
        value: 'CLEAN',
        enum: 'dropps_clean_detergent',
      },
      {
        value: 'SENSITIVE',
        enum: 'dropps_sensitive_detergent',
      },
      {
        value: 'USE OWN',
        enum: 'use_own_detergent',
      },
    ]
    
    softeners = [
      {
        value: 'CLEAN',
        enum: 'dropps_clean_softener',
      },
      {
        value: 'UNSCENTED',
        enum: 'dropps_unscented_softener',
      },
      {
        value: 'USE OWN',
        enum: 'use_own_softener',
      },
    ]

    @address = @current_user.address
    render json: {
      code: 200,
      status: 'ok',
      message: 'user_completed',
      detergents_for_select: detergents,
      softeners_for_select: softeners,
      price_per_bag: @current_user.address.region.price_per_bag,
      current_address: @address ? 
        {
          full_address: @address.full_address.upcase,
          pick_up_directions: @address.pick_up_directions,
          truncated_address: truncate_attribute(@address.street_address, 35).upcase,
          lat: @address.latitude,
          lng: @address.longitude 
        } : nil
    }
  end

  # POST
  # api_v1_users_resolve_setups_path
  # /api/v1/users/resolve_setups
  def create
    # sleep 1.seconds
    @address = @current_user.build_address(address_params)
    if @address.save
      @address.attempt_region_attach
      render(json: {
               code: 200,
               status: 'ok',
               message: 'address_saved',
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

  private

  def completed_setup?
    unless @current_user.completed_setup?
      render json: {
        code: 3000,
        message: 'setup_not_completed'
      }
    end
  end

  def within_region?
    unless @current_user.within_region?
      @address = @current_user.address
      render json: {
        code: 3000,
        message: 'outside_coverage_area',
        current_address: {
          full_address: @address.full_address.upcase,
          pick_up_directions: @address.pick_up_directions,
          truncated_address: truncate_attribute(@address.street_address, 35).upcase,
          lat: @address.latitude,
          lng: @address.longitude 
        }
      }
    end
  end

  def debug_undo
    @current_user.address.destroy
   end

  def address_params
    params.require(:address).permit(:street_address, :city, :state, :zipcode, :unit_number, :pick_up_directions)
  end
end
