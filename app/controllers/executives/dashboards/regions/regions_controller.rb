class Executives::Dashboards::Regions::RegionsController < ApplicationController
  before_action :authenticate_executive!
  layout 'executives/dashboard_layout'

  # executives_dashboards_regions_regions_path
  def index
    @regions = Region.all
  end

  # new_executives_dashboards_regions_region_pathx
  def new
    @region = Region.new
  end

  #executives_dashboards_regions_regions_path
  def create
    @region = Region.new(region_params)
    if @region.save
      flash[:success] = "Object successfully created"
      redirect_to executives_dashboards_regions_regions_path
    else
      flash[:error] = @region.errors.full_messages.first
      redirect_to new_executives_dashboards_regions_region_path
    end
  end

  # executives_dashboards_regions_region_path
  def show
    @region = Region.find(params[:id])
    @orders = @region.new_orders.order(created_at: :desc)
    @coverage_areas = @region.coverage_areas.order(created_at: :desc)
    @customers = @region.addresses.where.not(user_id: nil).order(created_at: :desc)
    
    @washers = @region.washers.order(created_at: :desc)
  end

  # edit_executives_dashboards_regions_region_path
  def edit
    @region = Region.find(params[:id])
  end

  # executives_dashboards_region_path
  def update
    @region = Region.find(params[:id])
      if @region.update_attributes(region_params)
        flash[:success] = "Region Updated Successfully!"
        redirect_to executives_dashboards_regions_region_path(@region.id)
      else
        flash[:error] = "Something went wrong"
        render 'edit'
      end
  end

  private
  def region_params
    params.require(:region).permit(%i[
      area
      tax_rate
      stripe_tax_rate_id
      business_open
      business_close
      washer_capacity
      price_per_bag
      washer_pay_percentage
      max_concurrent_offers
      failed_pickup_fee
    ])
  end
end