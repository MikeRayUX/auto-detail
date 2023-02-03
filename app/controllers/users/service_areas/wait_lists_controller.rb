class Users::ServiceAreas::WaitListsController < ApplicationController
  before_action :validate_zipcode, only: %i[create]

  layout 'static_pages/no_nav_layout'

  # new_users_service_areas_wait_list_path GET
  def new
    flash.clear
    @zipcode = params[:zipcode]
    @wait_list = WaitList.new
  end

  # users_service_areas_wait_lists_path POST
  def create
    @wait_list = WaitList.new(wait_list_params)

    if @wait_list.save
      redirect_to users_service_areas_wait_lists_path
    else
      flash[:notice] = @wait_list.errors.full_messages.first
      render :new
    end
  end

  # users_service_areas_wait_list_path GET
  def show; end

  private
  def validate_zipcode
    @zipcode = wait_list_params[:zipcode]
    unless @zipcode.present? && 
           @zipcode.length == 5 &&
           @zipcode.to_i > 0
      flash[:notice] = "Please enter a valid zipcode"
      render :new
    end
  end

  def wait_list_params
    params.require(:wait_list).permit(%i[email zipcode])
  end

end