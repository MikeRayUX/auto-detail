# frozen_string_literal: true

class Api::V1::Washers::Activations::BackgroundChecksController < Api::V1::Washers::AuthsController

  # /api/v1/washers/activations/background_checks/new GET
  # new_api_v1_washers_activations_background_check_path
  def new
    if @current_washer.not_submitted_background_check?
      render json: {
        status: :ok,
        code: 200,
        message: 'not_yet_submitted',
      }
    else 
      render json: {
        status: :ok,
        code: 200,
        message: 'already_submitted',
        errors: 'You have already completed this section.'
      }
    end
  end
  
  # /api/v1/washers/activations/background_checks/1 PUT
  # api_v1_washers_activations_background_check_path
  def update
    @current_washer.assign_attributes(washer_params)
    @address = @current_washer.build_address(address_params)

      if @current_washer.valid? && @address.valid? && @current_washer.not_submitted_background_check?
        @current_washer.save!
        @address.save!

        @current_washer.mark_background_check_submitted!
        
        render json: {
          status: :ok,
          code: 202,
          message: 'submitted_successfully'
        }
      else
        render json: {
          status: :ok,
          code: 3000,
          message: 'failure',
          errors: @current_washer.background_check_submitted_at.present? ? 'A background check has already been submitted.' : [@current_washer.errors.full_messages.first, @address.errors.full_messages.first].last
        }
      end
  end

  private

  def washer_params
    params.require(:washer).permit(%i[
       first_name
       middle_name
       last_name
       ssn
       phone
       date_of_birth
       drivers_license
      ]
    )
  end

  def address_params
    params.require(:address).permit(%i[
      street_address
      unit_number
      city
      state
      zipcode
    ]
  )
end
  
end
