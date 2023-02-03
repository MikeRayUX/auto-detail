class Api::V1::Washers::WorkFlows::ProcessOrders::WashCompletesController < Api::V1::Washers::AuthsController
  before_action :ensure_order_exists
  before_action :ensure_status

  # PUT
  # /api/v1/washers/work_flows/process_orders/wash_completes
  # api_v1_washers_work_flows_process_orders_wash_completes_path  
  def update
    if @order.completable?
      @order.mark_completed

      @minutes_since_pickup = ((DateTime.current.to_time - @order.picked_up_at) / 60).to_i

      OfferEvent.create!(
        new_order_id: @order.id,
        washer_id: @current_washer.id,
        event_type: 'order_processed',
        feedback: "Marked complete #{@minutes_since_pickup} minutes after pickup."
      )

      render json: {
        code: 204,
        message: 'completed_successfully'
      }
    else
      render json: {
        code: 3000,
        message: 'too_soon_to_complete',
        errors: "It is too soon to complete this order. You must wait until #{@order.min_completable_time}"
      }
    end
  end

  private
  def ensure_order_exists
    @order = @current_washer.new_orders.in_progress.find_by(ref_code: new_order_params[:ref_code])

    unless @order
      render json: {
        code: 3000,
        message: 'order_not_found',
        errors: 'This order cannot be found'
      }
    end
  end

  def ensure_status
    unless @order.status == 'picked_up'
      render json: {
        code: 3000,
        message: 'already_completed',
        errors: 'This has already been completed.'
      }
    end
  end

  def new_order_params
    params.require(:new_order).permit(%i[ref_code])
  end

end