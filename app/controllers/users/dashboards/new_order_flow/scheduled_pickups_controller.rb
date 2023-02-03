class Users::Dashboards::NewOrderFlow::ScheduledPickupsController < OrderableController
  include CalculateChargable

  layout 'users/dashboards/new_order_flow/order_layout'

  # /users/dashboards/new_order_flow/scheduled_pickups/new
  # new_users_dashboards_new_order_flow_scheduled_pickup_path
  def new
    @order = build_order_from_params
    @order.skip_finalization_attributes = true
    @order.skip_charge_validate = true

    if @order.valid?
      @address = current_user.address
      @region = @address.region

      @subtotal = NewOrder.calc_subtotal(@order.bag_count, @address.region.price_per_bag)
      @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate)
      @tax_rate = @region.tax_rate_percentage
    else
      redirect_to new_users_dashboards_new_order_flow_pickups_path, flash: {
        notice: @order.errors.full_messages.first
      }
    end
  end

  private
  def new_order_params
    params.require(:new_order).permit(%i[
      pickup_type
      detergent
      softener
      bag_count
      tip
      pickup_date
      pickup_time
    ])
  end

end