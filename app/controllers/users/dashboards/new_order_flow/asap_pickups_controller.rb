class Users::Dashboards::NewOrderFlow::AsapPickupsController < OrderableController
  include CalculateChargable

  layout 'users/dashboards/new_order_flow/order_layout'

  # /users/dashboards/new_order_flow/asap_pickups/new
  # new_users_dashboards_new_order_flow_asap_pickup_path
  def new
    @order = build_order_from_params
    @order.skip_finalization_attributes = true
    @order.skip_charge_validate = true
    
    if @order.valid?
      @address = current_user.address
      @region = @address.region

      @minutes = rand(55..65)
      @estimate = NewOrder.gen_pickup_estimate

      @readable_estimate = @estimate.strftime('%I:%M%P').upcase
      if @readable_estimate.first == '0'
        @readable_estimate = @readable_estimate[1...@readable_estimate.length]
      end

      @subtotal = NewOrder.calc_subtotal(@order.bag_count, @address.region.price_per_bag)
      @tax = NewOrder.calc_tax(@subtotal, @region.tax_rate)
      @tax_rate = @region.tax_rate_percentage
    else
      redirect_to new_users_dashboards_new_order_flow_pickups_path, flash: {
        notice: @order.errors.full_messages.first
      }
    end
  end

  # /users/dashboards/new_order_flow/asap_pickups
  # users_dashboards_new_order_flow_asap_pickups_path
  def create
    @address = current_user.address
    @region = @address.region

    @order = build_with_charge
    @order.skip_charge_validate = true

    if @order.valid?
      @order.charge_order!(current_user)
      @order.save!
      @order.send_new_order_email!(@region, current_user, @address)
      @order.alert_washers_in_region!

      redirect_to users_dashboards_new_order_flow_track_pickup_path(id: @order.ref_code)
    else
      redirect_to new_users_dashboards_new_order_flow_asap_pickup_path, flash: {
        notice: @order.errors.full_messages.first
      }
    end

    rescue Stripe::StripeError => e
      redirect_to new_users_dashboards_new_order_flow_pickups_path, flash: {
       notice: e
      }
  end

  # /users/dashboards/new_order_flow/asap_pickups/:id
  # users_dashboards_new_order_flow_asap_pickup_path
  def show
    @order = current_user.new_orders.find_by(ref_code: params[:id])
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