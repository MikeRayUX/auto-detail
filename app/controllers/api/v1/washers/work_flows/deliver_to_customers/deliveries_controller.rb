class Api::V1::Washers::WorkFlows::DeliverToCustomers::DeliveriesController < Api::V1::Washers::AuthsController
  before_action :authenticate_washer!
  before_action :ensure_current_location
  before_action :ensure_order_exists
  before_action :ensure_status
  # before_action :ensure_photo_and_location

  include Formattable

  # PUT
  # /api/v1/washers/work_flows/deliver_to_customers/deliveries
  # api_v1_washers_work_flows_deliver_to_customers_deliveries_path
  def update
    # disabled for testing IRL
    # if @order.washer_within_arrival_range?(current_location_params)
    if true
      @user = @order.user
      @order.mark_delivered
      @order.save_delivery_data(new_order_params)
      @order.send_delivered_email!(@user)

      @user.send_sms_notification!(
        'order_delivered',
        @order,
        "#{@current_washer.abbrev_name} just delivered your FreshAndTumble.com laundry order. So fresh and clean!"
      )
      
      if delivered_early?
        @minutes = ((@order.est_delivery - @order.delivered_at) / 60).to_i
        @feedback = "(#{@minutes} MINUTES EARLY)"
      else
        @minutes = ((@order.delivered_at - @order.est_delivery) / 60).to_i
        @feedback = "(#{@minutes} MINUTES LATE)"
      end

      OfferEvent.create!(
        event_type: 'delivered',
        new_order_id: @order.id,
        washer_id: @current_washer.id,
        feedback: "#{@order.readable_delivery_location} #{@feedback}"
      )

      @order.payout_washer!

      render json: {
        code: 204,
        message: 'delivery_completed'
      }
    else
      render json: {
        code: 3000,
        message: 'not_close_enough',
        errors: 'You must get closer to the delivery address to complete this delivery.'
      }
    end

    rescue Stripe::StripeError => e
      @order.update(stripe_transfer_error: e)

      render json: {
        code: 204,
        message: 'delivery_completed'
      }
  end

  private

  def delivered_early?
    DateTime.current < @order.est_delivery
  end
  def new_order_params
    params.require(:new_order).permit(%i[ref_code delivery_location delivery_photo_base64])
  end

  def current_location_params
    params.require(:current_location).permit(%i[lat lng])
  end

  def ensure_current_location
    unless current_location_params[:lat].present? && current_location_params[:lng].present?
      render json: {
        code: 3000,
        message: 'location_required',
      }
    end
  end

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

  def ensure_photo_and_location
    unless new_order_params[:delivery_location].present? && new_order_params[:delivery_photo_base64].present?
      render json: {
        code: 3000,
        message: 'delivery_params_missing'
      }
    end
  end

  def ensure_status
    unless @order.status == 'completed'
      render json: {
        code: 3000,
        message: 'already_delivered',
        errors: 'This has already been delivered.'
      }
    end
  end
end