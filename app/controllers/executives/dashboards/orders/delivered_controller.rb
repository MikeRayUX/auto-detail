class Executives::Dashboards::Orders::DeliveredController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_orders_delivered_index_path GET
  def index
    @orders = Order.all
    
    @delivered = @orders.delivered.order('delivered_to_customer_at DESC')
  end
end