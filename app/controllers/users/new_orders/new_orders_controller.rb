class Users::NewOrders::NewOrdersController < ApplicationController
  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout'

  # GET
  # /users/new_orders/new_orders
  # users_new_orders_new_orders_path
  def show
    @new_order = current_user.new_orders.find_by(ref_code: params[:ref_code])
  end

  # PUT
  # /users/new_orders/new_orders
  # users_new_orders_new_orders_path
  def update
    # cancel
  end 

  # private
  # def new_order_params
  #   params.require(:new_order).permit(%i[ref_code])
  # end
end