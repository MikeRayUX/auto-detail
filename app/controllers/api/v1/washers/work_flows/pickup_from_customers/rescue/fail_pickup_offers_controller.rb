class Api::V1::Washers::WorkFlows::PickupFromCustomers::Rescue::FailPickupOffersController < Api::V1::Washers::AuthsController
  before_action :ensure_order_exists
  before_action :ensure_status

  # PUT
  # api_v1_washers_work_flows_pickup_from_customers_rescue_fail_pickup_offers_path
  # /api/v1/washers/work_flows/pickup_from_customers/rescue/fail_pickup_offers
  def update
    @user = @order.user
    @region = @current_washer.region
    @order.soft_cancel

    @failed_pickup_fee = (@region.failed_pickup_fee * 100).to_i
    @transaction = @order.get_stripe_transaction
    @refund_amount = @order.grandtotal - @region.failed_pickup_fee
    @stripe_refund_amount = @transaction.amount - @failed_pickup_fee

    @order.partial_refund!(@stripe_refund_amount)

    @order.update(
      washer_final_pay: (@failed_pickup_fee / 100.00),
      payout_desc: "Unable To Pickup: $#{format('%.2f', (@failed_pickup_fee / 100.00))}",
      refunded_amount: @refund_amount
    )
    
    if @current_washer.payoutable_as_ic
      @order.custom_washer_payout(@failed_pickup_fee)
    end

    @offer_event = OfferEvent.create!(
      offer_event_params.merge(
        new_order_id: @order.id,
        washer_id: @current_washer.id
      )
    )

    @order.send_failed_pickup_email!(@user, @offer_event, @region.failed_pickup_fee)

    render json: {
      code: 204,
      message: 'pickup_failed_successfully'
    }

  rescue Stripe::StripeError => e
    render json: {
      code: 204,
      message: 'pickup_failed_successfully'
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
    unless @order.status == 'arrived_for_pickup'
      render json: {
        code: 3000,
        message: 'invalid_order_status'
      }
    end
  end


   # p '****NEW ORDER********'
      # p "bag price: $#{@order.bag_price}"
      # p "tax: $#{format('%.2f', @order.tax)}"
      # p "subtotal: $#{format('%.2f',@order.subtotal)}"
      # p "grandtotal: $#{format('%.2f', @order.grandtotal)}"
      # p "bags: #{@order.bag_count}"
      # p "tip: $#{format('%.2f', @order.tip)}"
      # p "washer ppb $#{format('%.2f', @order.washer_ppb)}"
      # p "washer pay: $#{format('%.2f', @order.washer_pay)}"
      # p "washer final pay: $#{format('%.2f', @order.washer_final_pay)}"
      # p "washer percentage #{(@order.region.washer_pay_percentage * 100).to_i}%"
      # p "profit: $#{format("%.2f", @order.profit)}"
      # p "raw transaction grandtotal: #{@transaction.amount}"
      # p "raw fee: #{@fee}"
      # p "raw refund amount: #{@refund_amount}"
      # p "transaction grandtotal: $#{format("%.2f", (@transaction.amount / 100.00))}"
      # p "washer failed pickup fee: $#{format("%.2f", (@fee / 100.00))}"
      # p "refund_amount: $#{format("%.2f", (@refund_amount / 100.00))}"


end