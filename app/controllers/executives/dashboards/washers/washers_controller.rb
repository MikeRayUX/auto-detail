class Executives::Dashboards::Washers::WashersController < ApplicationController
  before_action :authenticate_executive!
  before_action :region_has_capacity?, only: %i[create]
  layout 'executives/dashboard_layout'

  # executives_dashboards_washers_washers_path GET
  def index
    @washers = Washer.all.order(created_at: :desc)
  end

  # new_executives_dashboards_washers_washer_path
  def new
    @washer = Washer.new
  end
    
  # executives_dashboards_washers_washer_path GET
  def show
    @w = Washer.find(params[:id])
    @events = @w.offer_events.order(created_at: :asc)
    # @address = @washer.address
  end

  # FOR MANUAL WASHER CREATION ONLY
  # executives_dashboards_washers_washers_path
  def create
    @manual_washer = ManualWasher.new(manual_washer_params)
    if @manual_washer.save
      @washer = @manual_washer.washer
      flash[:success] = "Washer Successfully Created"
      redirect_to executives_dashboards_washers_washer_path(@washer.id)
    else
      flash[:error] = @manual_washer.errors.full_messages.first
      render :new
    end
  end

  def update; end

  def destroy; end

  def manual_washer_params
    params.require(:manual_washer).permit(%i[
      email
      full_name
      first_name
      middle_name
      last_name
      region_id
      ssn
      date_of_birth
      phone
      drivers_license
      street_address
      unit_number
      city
      state
      zipcode
      payoutable_as_ic
      ])
  end

  def region_has_capacity?
    @region = Region.find(manual_washer_params[:region_id])

    unless @region.washers.count < @region.washer_capacity
      flash[:error] = "Region: #{@region.area.upcase} does not have enough capacity to add another washer. "
      render :new
    end
  end
end