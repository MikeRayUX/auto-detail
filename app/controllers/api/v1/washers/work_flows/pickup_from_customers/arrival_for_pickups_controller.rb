class Api::V1::Washers::WorkFlows::PickupFromCustomers::ArrivalForPickupsController < Api::V1::Washers::AuthsController
  before_action :authenticate_washer!
  before_action :ensure_order_exists
  before_action :ensure_location_passed
  before_action :ensure_status

  # PUT
  # /api/v1/washers/work_flows/pickup_from_customers/arrival_for_pickups/1
  # api_v1_washers_work_flows_pickup_from_customers_arrival_for_pickup_path
  def update
    if @order.washer_within_arrival_range?(current_location_params)
      @user = @order.user
      @order.mark_arrived_for_pickup
      @user.send_sms_notification!(
        'arrival_for_pickup',
        @order,
        "#{@current_washer.abbrev_name} has arrived for your laundry pickup."
      )
      render json: {
        code: 204,
        message: 'arrived_successfully'
      }
    else
      render json: {
        code: 3000,
        message: 'not_close_enough',
        errors: 'You must get close to the address in order to mark yourself as arrived'
      }
    end
  end

  private
  def ensure_order_exists
    @order = @current_washer.new_orders.in_progress.find_by(ref_code: new_order_params[:ref_code])

    unless @order
      render json: {
        code: 3000,
        message: 'order_not_found'
      }
    end
  end

  def ensure_location_passed
    unless current_location_params[:lat].present? && current_location_params[:lng].present?
      render json: {
        code: 3000,
        message: 'missing_location'
      }
    end
  end

  def ensure_status
    unless @order.status == 'enroute_for_pickup'
      render json: {
        code: 3000,
        message: 'already_arrived'
      }
    end
  end

  def current_location_params
    params.require(:current_location).permit(%i[lat lng])
  end

  def new_order_params
    params.require(:new_order).permit(%i[ref_code])
  end

end