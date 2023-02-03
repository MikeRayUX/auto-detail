class Users::ServiceAreas::VerifyZipcodesController < ApplicationController
  layout 'static_pages/no_nav_layout'

  before_action :validate_zipcode, only: %i[create]

  # new_users_service_areas_verify_zipcodes_path GET
  def new
    flash.clear
  end

  # users_service_areas_verify_zipcode_path POST
  def create
    @zipcode = zipcode_params[:zipcode]

    if CoverageArea.find_by(zipcode: @zipcode).present?
      flash.clear
      redirect_to signup_path
    else
      redirect_to new_users_service_areas_wait_lists_path(zipcode: @zipcode)
    end
  end

  private
  def validate_zipcode
    @zipcode = zipcode_params[:zipcode]
    unless @zipcode.present? && 
           @zipcode.length == 5 &&
           @zipcode.to_i > 0
      flash[:notice] = "Please enter a valid zipcode"
      render :new
    end
  end

  def zipcode_params
    params.require(:zipcode).permit(%i[zipcode])
  end
end