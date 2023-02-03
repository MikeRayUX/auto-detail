class Api::V1::Washers::WorkFlows::CurrentWork::OfferEventsController < Api::V1::Washers::AuthsController
  before_action :washer_activated?
  before_action :order_exists?

  # /api/v1/washers/work_flows/current_work/offer_events
  # api_v1_washers_work_flows_current_work_offer_events_path
  def create
    @offer_event = @current_washer.offer_events.new(
      offer_event_params.merge(
        new_order_id: @order.id,
      )
    )

    if @offer_event.save
      render json: {
        code: 201,
        message: 'offer_event_created'
      }
    else
      render json: {
        code: 3000,
        message: 'offer_event_error',
        errors: @offer_event.errors.full_messages.first
      }
    end
  end

  private

  def new_order_params
    params.require(:new_order).permit(%i[ref_code])
  end

  def offer_event_params
    params.require(:offer_event).permit(%i[event_type feedback])
  end

  def washer_activated?
    unless @current_washer.activated?
      render json: {
        code: 3000,
        message: 'not_activated',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
      }
    end
  end

  def order_exists?
    @order = @current_washer.new_orders.in_progress.find_by(ref_code: new_order_params[:ref_code])

    unless @order
      render json: {
        code: 3000,
        message: 'order_not_found'
      }
    end
  end
end