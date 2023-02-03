# frozen_string_literal: true

class Users::Dashboards::OrdersOverviewsController < ApplicationController
  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout'
  
  # users_dashboards_orders_overviews_path GET
  def index
    @orders = current_user.orders.order(created_at: :desc)
    @new_orders = current_user.new_orders.order(created_at: :desc)
  end
end
