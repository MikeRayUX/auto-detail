class Api::V1::Washers::WorkFlows::PickupFromCustomers::Rescue::OverrideArrivedForPickupsController < Api::V1::Washers::AuthsController
  before_action :ensure_order_exists
  before_action :ensure_status

  # PUT
  # /api/v1/washers/work_flows/pickup_from_customers/rescue/override_arrived_for_pickups
  # api_v1_washers_work_flows_pickup_from_customers_rescue_override_arrived_for_pickups_path
  def update
    @user = @order.user
    @order.mark_arrived_for_pickup
    @user.send_sms_notification!(
      'arrival_for_pickup',
      @order,
      "#{@current_washer.abbrev_name} has arrived for your laundry pickup."
    )

    OfferEvent.create!(
      offer_event_params.merge(
        new_order_id: @order.id,
        washer_id: @current_washer.id
      )
    )

    render json: {
      code: 204,
      message: 'arrived_successfully'
    }
  end

  private

  def new_order_params
    params.require(:new_order).permit(%i[ref_code])
  end

  def offer_event_params
    params.require(:offer_event).permit(%i[event_type feedback])
  end

  def ensure_order_exists
    @order = @current_washer.new_orders.in_progress.find_by(ref_code: new_order_params[:ref_code])

    unless @order
      render json: {
        code: 3000,
        message: 'order_not_found',
        errors: 'offer not found'
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
end