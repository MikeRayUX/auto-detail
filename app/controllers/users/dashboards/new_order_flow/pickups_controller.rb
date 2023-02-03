class Users::Dashboards::NewOrderFlow::PickupsController < OrderableController
  include CalculateChargable
  
  layout 'users/dashboards/new_order_flow/order_layout'

  # GET
  # /users/dashboards/new_order_flow/pickup/new
  # new_users_dashboards_new_order_flow_pickups_path
  def new
    @region = current_user.region
    @price_per_bag = @region.price_per_bag.to_i
    @detergents = NewOrder::DETERGENTS
    @softeners = NewOrder::SOFTENERS
  end

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