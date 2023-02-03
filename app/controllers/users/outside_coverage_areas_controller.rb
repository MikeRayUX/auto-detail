class Users::OutsideCoverageAreasController < ApplicationController
  before_action :authenticate_user!
  layout 'users/dashboards/user_dashboard_layout'

  # GET
  # /users/outside_coverage_areas
  # users_outside_coverage_areas_path
  def show
  end
end