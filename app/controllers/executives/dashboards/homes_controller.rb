class Executives::Dashboards::HomesController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_homes_path GET
  def index
  end

end
