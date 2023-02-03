class Users::Orders::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_request!

  layout 'users/dashboards/user_dashboard_layout'

  # users_orders_orders_path GET
  def show
    @order = Order.find_by(reference_code: params[:reference_code])
  end

  # cancel order
  # users_orders_orders_path PATCH PUT
  def update
    @order = Order.find_by(reference_code: params[:reference_code])

    if @order.present? && @order.cancellable_by_customer?
      @order.cancel! && @order.send_cancelled_email! &&
      @order.notify_worker_cancelled!

      redirect_to users_dashboards_orders_overviews_path,
                  flash: {
                    notice: 'Your Order Has Been Cancelled.'
                  }
    else
      redirect_to users_dashboards_orders_overviews_path,
                  flash: {
                    notice: 'This Order Cannot Be Cancelled'
                  }
    end
  end
 
  private

  def validate_request!
   unless params[:reference_code].present? && Order.find_by(reference_code: params[:reference_code]).present? && current_user.owns_order?(params[:reference_code])
    redirect_to users_dashboards_orders_overviews_path, flash: {
      notice: "That order doesn't exist, or you don't have permission to view it."
    }
    end
  end

end
