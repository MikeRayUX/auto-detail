class Api::V1::Users::Dashboards::NewOrderFlow::RefreshWaitForWashersController < ApiController
  before_action :ensure_order_exists, only: %i[update]
  
  # /api/v1/users/dashboards/new_order_flow/refresh_wait_for_washers/1
  # api_v1_users_dashboards_new_order_flow_refresh_wait_for_washer_path
  # put
  def update
    if @order.wait_for_washer_refreshable?
      @order.refresh_wait_for_washer
      render json: {
        code: 204,
        message: 'offer_refreshed'
      }
    else 
      render json: {
        code: 3000,
        message: 'not_refreshable'
      }
    end
  end

  def ensure_order_exists
    @order = @current_user.new_orders.find_by(ref_code: new_order_params[:ref_code])
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