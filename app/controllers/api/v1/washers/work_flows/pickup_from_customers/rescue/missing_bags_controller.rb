class Api::V1::Washers::WorkFlows::PickupFromCustomers::Rescue::MissingBagsController < Api::V1::Washers::AuthsController
  before_action :ensure_order_exists
  before_action :ensure_status
  before_action :already_adjusted?
  before_action :bag_count_adjustable?

  include Formattable

  # after_action :debug_reverse_changes

  # PUT
  # api_v1_washers_work_flows_pickup_from_customers_rescue_missing_bags_path
  # /api/v1/washers/work_flows/pickup_from_customers/rescue/missing_bags
  def update
    @user = @order.user
    @old_bag_count = @order.bag_count
    @new_bag_count =  @old_bag_count - @missing_bags_count
    @order.washer_adjust_bag_count(@new_bag_count)

    OfferEvent.create!(
      event_type: 'bags_missing_pickup',
      new_order_id: @order.id,
      washer_id: @current_washer.id,
      feedback: "WAS (#{@old_bag_count}), IS NOW (#{@new_bag_count})"
    )

    @order.send_missing_bags_email!(@user, @old_bag_count, @missing_bags_count)

    render json: {
      code: 204,
      message: 'bag_count_adjusted_successfully',
      current_offer: {
        ref_code: @order.ref_code,
        status: @order.status,
        bags_to_scan: @order.bag_count,
        bag_codes: @order.bag_codes,
        pay: @order.readable_washer_pay,
        failed_pickup_fee: readable_decimal(@order.failed_pickup_fee),
        detergent: @order.readable_detergent,
        softener: @order.readable_softener,
        picked_up_at: @order.picked_up_at,
        wash_notes: @order.wash_notes,
        return_by: @order.est_delivery,
        todo: @order.current_todo,
        readable_return_by: "#{@order.est_delivery.strftime('%m/%d/%Y by %I:%M%P')}".upcase,
        scheduled: @order.scheduled_pickup,
        readable_scheduled: @order.readable_scheduled,
        customer: {
          full_name: @user.full_name.upcase,
          phone: @user.formatted_phone
        },
        address: {
          address: @order.address,
          directions: @order.directions,
          full_address: @order.full_address.upcase,
          unit_number: @order.unit_number,
          lat: @order.address_lat,
          lng: @order.address_lng
        }
      }
    }
  end

  private
  def new_order_params
    params.require(:new_order).permit(%i[ref_code missing_bags_count])
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

  def event_params_present?
    unless offer_event_params[:event_type].present? && offer_event_params[:feedback].present?

      render json: {
        code: 3000,
        message: 'event_params_missing'
      }
    end
  end

  def bag_count_adjustable?
    @missing_bags_count = new_order_params[:missing_bags_count].to_i
    unless @missing_bags_count > 0 && @missing_bags_count < @order.bag_count
      render json: {
        code: 3000,
        message: 'not_adjustable'
      } 
    end
  end

  def already_adjusted?
    unless @order.washer_adjusted_bag_count_at.blank?
      render json: {
        code: 3000,
        message: 'already_adjusted',
        errors: 'Cannot adjust the bag count of this order more than once.'
      }
    end
  end

  # debug (reversal for app ui)
  def debug_reverse_changes
    OfferEvent.destroy_all
    # @order.update(bag_count: @old_bag_count, washer_adjusted_bag_count_at: nil)
  end 
end