class Executives::Dashboards::Orders::InProgressesController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_orders_in_progresses_path GET
  def index
    @orders = Order.in_progress.order('created_at DESC')
  end
end