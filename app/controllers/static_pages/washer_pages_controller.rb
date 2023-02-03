# frozen_string_literal: true
class StaticPages::WasherPagesController < ApplicationController
  layout 'static_pages/no_nav_layout'

  # washers_apply_path
  def new
    @washer = WasherApplication.new

    @regions = Region.all
  end

  # static_pages_washer_pages_path
  def create
    @washer_application = WasherApplication.new(washer_application_params)

    if @washer_application.save
      @washer_application.washer.send_application_received_email!
      redirect_to washers_application_success_path
    else
      flash[:error] = @washer_application.errors.full_messages.first
      redirect_to washers_apply_path
    end
  end

  # washers_application_success_path
  def index
    # application success
  end

  private
  def washer_application_params
    params.require(:washer_application).permit(%i[
      full_name
      email
      phone
      region_id
      live_within_region
      min_age
      legal_to_work
      has_equipment
      valid_drivers_license
      valid_car_insurance_coverage
      reliable_transportation
      valid_ssn
      can_lift_30_lbs
      consent_to_background_check
      has_disability
      unit_number
      city
      state
      zipcode
      street_address
    ])
  end
end
