class Users::Dashboards::NewOrderFlow::CancelPickupsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :ensure_order_exists, only: %i[update]

  layout 'users/dashboards/new_order_flow/order_layout'
  
  # /users/dashboards/new_order_flow/cancel_pickups/1
  # users_dashboards_new_order_flow_cancel_pickup_path
  # put
  def update
    if @order.cancellable?
      @order.cancel!
      @order.send_cancelled_order_email!(current_user)
      render json: {
        code: 204,
        message: 'order_cancelled'
      }
    else
      render json: {
        code: 3000,
        message: 'not_cancellable',
        errors: 'Your order is already in progress and cannot be cancelled'
      }
    end
  end

  private

  def offer_event_params
    params.require(:offer_event).permit(%i[event_type feedback])
  end

  def ensure_order_exists
    @order = current_user.new_orders.find_by(ref_code: new_order_params[:ref_code])
    unless @order
      render json: {  
        code: 3000,
        message: 'order_not_found',
        order_status: 'order_not_found'
      }
    end
  end


  def new_order_params
    params.require(:new_order).permit(%i[ref_code])
  end
end