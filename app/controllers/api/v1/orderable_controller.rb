class Api::V1::OrderableController < ApiController
  before_action :has_address?
  before_action :address_within_region?
  # before_action :has_active_subscription?
  before_action :ensure_no_in_progress_orders
  
  private
  def has_address?
    unless @current_user.address
      render json: {
        code: 3000,
        message: 'setup_not_resolved',
        errors: 'You must first have an address to continue.'
      }
    end
  end

  def address_within_region?
    unless @current_user.address.region
      render json: {
        code: 3000,
        message: 'outside_coverage_area',
      }
    end
  end

  def ensure_no_in_progress_orders
    unless @current_user.new_orders.in_progress.none?
      render json: {
        code: 3000,
        message: 'order_already_in_progress',
        errors: 'You already have an order that is in progress.'
      }
    end
  end

  # def has_active_subscription?
  #   unless @current_user.has_active_subscription?
  #     redirect_to users_resolve_subscriptions_path
  #   end 
  # end

  def build_order_from_params
    @region = @current_user.region

    @current_user.new_orders.new(
      new_order_params.merge(
        region_id: @region.id,
        bag_price: @region.price_per_bag,
        est_delivery: DateTime.current + 24.hours,
      )
      )
  end
end