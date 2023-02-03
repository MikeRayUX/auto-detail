class OrderableController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :has_address?
  before_action :address_within_region?
  # before_action :has_active_subscription?
  before_action :ensure_no_in_progress_orders
  
  private
  def has_address?
    unless current_user.address
      redirect_to users_resolve_setups_path
    end
  end

  def address_within_region?
    unless current_user.address.region
      redirect_to users_dashboards_new_order_flow_outside_service_areas_path
    end
  end

  def has_active_subscription?
    unless current_user.has_active_subscription?
      redirect_to users_resolve_subscriptions_path
    end 
  end

  def build_order_from_params
    @region = current_user.region

    current_user.new_orders.new(
      new_order_params.merge(
        region_id: @region.id,
        bag_price: @region.price_per_bag,
        est_delivery: DateTime.current + 24.hours,
      )
      )
  end

  def ensure_no_in_progress_orders
    unless current_user.new_orders.in_progress.none?
      redirect_to users_dashboards_homes_path, flash: {
        notice: 'You already have an order that is in progress.'
      }
    end
  end
end