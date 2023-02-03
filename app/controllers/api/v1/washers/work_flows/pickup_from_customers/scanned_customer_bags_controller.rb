class Api::V1::Washers::WorkFlows::PickupFromCustomers::ScannedCustomerBagsController < Api::V1::Washers::AuthsController
  before_action :authenticate_washer!
  before_action :ensure_order_exists
  before_action :ensure_codes_passed
  before_action :ensure_status

  # PUT
  # /api/v1/washers/work_flows/pickup_from_customers/scanned_customer_bags/1
  # api_v1_washers_work_flows_pickup_from_customers_scanned_customer_bag_path
  def update
    @parsed = JSON.parse(new_order_params[:bag_codes])

    if @parsed.count == @order.bag_count
      @order.mark_picked_up(@parsed)
      @user = @order.user
      @user.send_sms_notification!(
        'order_picked_up',
        @order,
        "#{@current_washer.abbrev_name.titleize} just picked up your laundry. Enjoy your fresh laundry in less than 24 hours!"
      )


      if pickup_early?
        @minutes = ((@order.est_pickup_by - @order.picked_up_at) / 60).to_i
        @feedback = "(#{@minutes} MINUTES EARLY)"
      else
        @minutes = ((@order.picked_up_at - @order.est_pickup_by) / 60).to_i
        @feedback = "(#{@minutes} MINUTES LATE)"
      end

      OfferEvent.create!(
        washer_id: @current_washer.id,
        new_order_id: @order.id,
        event_type: 'completed_pickup',
        feedback: @feedback
      )

      render json: {
        code: 204,
        message: 'picked_up_successfully'
      }
    else
      render json: {
        code: 3000,
        message: 'codes_do_not_match',
        errors: 'The codes you entered are invalid. Please scan the correct codes.'
      }
    end
  end

  private
  def pickup_early?
    DateTime.current < @order.est_pickup_by
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

  def ensure_codes_passed
    unless new_order_params[:bag_codes].present?
      render json: {
        code: 3000,
        message: 'missing_codes',
        errors: 'You must pass at least one bag code'
      }
    end
  end

  def ensure_status
    unless @order.status == 'arrived_for_pickup'
      render json: {
        code: 3000,
        message: 'already_picked_up'
      }
    end
  end

  def new_order_params
    params.require(:new_order).permit(%i[ref_code bag_codes])
  end

end