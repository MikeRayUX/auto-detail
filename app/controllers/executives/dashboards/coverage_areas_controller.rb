class Executives::Dashboards::CoverageAreasController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_coverage_areas_path
  def index
    @regions = Region.all
  end

  # new_executives_dashboards_coverage_area_path
  def new
    @coverage_area = CoverageArea.new
    @region = Region.find(params[:region_id])
  end

  # executives_dashboards_coverage_areas_path POST
  def create
    @area = CoverageArea.new(coverage_area_params)
    if @area.save
      Address::find_and_link_regions
      redirect_to executives_dashboards_region_path(@area.region_id), flash: { notice: 'Coverage Area Added' }
    else
      redirect_to executives_dashboards_region_path(@area.region_id), flash: { notice: @area.errors.full_messages.first }
    end
  end

  # executives_dashboards_coverage_area_path DELETE
  def destroy
    @area = CoverageArea.find(params[:id])
    @region = @area.region

    if @area.destroy
      Address::find_and_link_regions
      redirect_to executives_dashboards_region_path(@region.id), flash: {notice: 'Coverage Area Deleted'}
    else 
      redirect_to executives_dashboards_region_path(@region.id), flash: {
      notice: @area.errors.full_messages.first
    }
    end
  end

  private
  def coverage_area_params
    params.require(:coverage_area).permit(
      %i[
        zipcode
        state
        county
        city
        region_id
      ]
    )
  end 
end
